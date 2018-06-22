
local file_transfer_endpoints = {}

function file_transfer_endpoints.validate_upload_request()

    -- Add headers from gatekeeper response
       ngx.req.set_header("Concent-Checksum", ngx.var.checksum)
       ngx.req.set_header("Concent-File-Size", ngx.var.size)

    -- Make sure that Concent-Upload-Path header with path and filename were included with the request.
    if ngx.req.get_headers()["Concent-Upload-Path"] == nil then
        ngx.status = 400
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say('{"error_message": "Concent-Upload-Path header is missing.", "error_code": "missing-header"}')
        return ngx.exit(400)
    end

    -- Make sure that Concent-Checksum header was included with the request.
    if ngx.req.get_headers()["Concent-Checksum"] == nil then
        ngx.status = 502
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say('{"error_message": "Concent-Checksum header is missing.", "error_code": "missing-header"}')
        return ngx.exit(502)
    end

    -- Make sure that Concent-File-Size header was included with the request.
    if ngx.req.get_headers()["Concent-File-Size"] == nil then
        ngx.status = 502
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say('{"error_message": "Concent-File-Size header is missing.", "error_code": "missing-header"}')
        return ngx.exit(502)
    end

    -- Make sure that the request actually has a body.
    if ngx.req.get_headers()["Content-Length"] == "0" then
        ngx.status = 400
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say('{"error_message": "The file to be uploaded must not be empty.", "error_code": "empty-file"}')
        return ngx.exit(400)
    end

    -- Strip the X-Session-Id header from the request if client has provided it.
    -- nginx-big-upload uses this header to set the name of the temporary file.
    -- If it's empty, a random name will be generated and that's exactly what we want.
    ngx.req.set_header("X-Session-Id", "")

    -- Strip the X-SHA1 header from the request if client has provided it.
    -- nginx-big-upload uses this header to compare hash provided by client to the hash of the uploaded file.
    -- In our case the hash is not supposed to be provided by the client so we disable this by removing the header even if the client sends it.
    -- We get it from gatekeeper and letting client set it would allow it to cheat.
    ngx.req.set_header("X-SHA1", "")
end

function file_transfer_endpoints.validate_uploaded_file()

    nginx_big_upload_request_body   = ngx.req.get_body_data()
    tmp_file_name                   = string.match(nginx_big_upload_request_body, 'id=(.-)&')
    checksum_from_nginx_big_upload  = "sha1:" .. string.match(nginx_big_upload_request_body, 'sha1=(.-)&')
    file_size_from_nginx_big_upload = string.match(nginx_big_upload_request_body,'size=(.-)&')

    -- Now that the file has successfully finished uploading, we can check if the hashes of file are the same.
    -- Accept the hash from Concent-Checksum header. We assume that this header was validated by
    -- the gatekeeper app and is safe to use.
    checksum_from_gatekeeper = ngx.req.get_headers()["Concent-Checksum"]
    if checksum_from_nginx_big_upload ~= checksum_from_gatekeeper then
        ngx.status = 400
        ngx.header.content_type    = "application/json; charset=utf-8"
        -- Nginx big upload module adds headers with checksum and temporary file name to its response.
        -- We don't want to return them to the client.
        -- FIXME: Setting it to an empty string does not remove the headers. For now we set it to a
        -- single space to work around this but we should really just find a way to remove those headers.
        ngx.header["X-SHA1"]       = " "
        ngx.header["X-Session-Id"] = " "
        ngx.say('{"error_message": "File checksum does not match the token", "error_code": "checksum-mismatch"}')
        os.remove("/srv/storage/" .. tmp_file_name)
        os.remove("/srv/storage/" .. tmp_file_name .. ".shactx")
        return ngx.exit(400)
   end

   -- Check file size.
   -- Accept the size from Concent-File-Size header. We assume that this header was validated by
   -- the gatekeeper app and is safe to use.
   file_size_from_gatekeeper = ngx.req.get_headers()["Concent-File-Size"]
   if file_size_from_nginx_big_upload ~= file_size_from_gatekeeper then
        ngx.status = 400
        ngx.header.content_type    = "application/json; charset=utf-8"
        -- Nginx big upload module adds headers with checksum and temporary file name to its response.
        -- We don't want to return them to the client.
        -- FIXME: Setting it to an empty string does not remove the headers. For now we set it to a
        -- single space to work around this but we should really just find a way to remove those headers.
        ngx.header["X-SHA1"]       = " "
        ngx.header["X-Session-Id"] = " "
        ngx.say('{"error_message": "File size does not match the token", "error_code": "file-size-mismatch"}')
        os.remove("/srv/storage/" .. tmp_file_name)
        os.remove("/srv/storage/" .. tmp_file_name .. ".shactx")
        return ngx.exit(400)
   end
end

function file_transfer_endpoints.create_upload_location()

    local lfs   = require('lfs_ffi')
    local utils = require('pl.utils')
    local table_utils   = require('table_utils')


    -- Move the file to its final location.
    -- Accept the name from Concent-Upload-Path header. We assume that this header was validated by
    -- the gatekeeper app and is safe to use. In particular, the path must be relative.
    header_path_with_filename = ngx.req.get_headers()["Concent-Upload-Path"]
    path_parts                = utils.split('/srv/storage/' .. header_path_with_filename, '/')
    path                      = ""
    for index, path_part in pairs(path_parts) do

        -- Create all intermediate directories on the path. Ignore the last part (which is the file name)
        local size = table_utils.length(path_parts) - 1
        if index <= size then
            path = path .. path_part .. '/'
            lfs.mkdir(path)
        end
    end

    os.rename("/srv/storage/" .. tmp_file_name, "/srv/storage/" .. header_path_with_filename)
    os.remove("/srv/storage/" .. tmp_file_name .. ".shactx")
end

function file_transfer_endpoints.report_upload()

    -- Send confirmation to the conductor when a file is uploaded.
    local http = require "resty.http"
    local file_transfer_config = require('config.file-transfer-config')
    local httpc = http.new()
    local conductor_response, conductor_error = httpc:request_uri( file_transfer_config.upload_report_url .. header_path_with_filename, {
        method = "POST",
    })

    if conductor_response == nil then
        ngx.status = 500
        conductor_connection_error = '{"error_message": "HTTP request to conductor failed:' .. conductor_error .. '", "error_code": "failed-conductor-request"}'
        ngx.say(conductor_connection_error)
        ngx.log(ngx.ERR, conductor_connection_error)
        return ngx.exit(ngx.status)
    end

    if not (200 <= conductor_response.status and conductor_response.status < 300) then
        ngx.status = 502
        error_response = '{' ..
            '"error_message": "Failed to report upload. Conductor responded with status {' .. conductor_response.status .. '}", ' ..
            '"error_code": "failed-upload-report", ' ..
            '"conductor_message": "' .. conductor_response.body .. '"' ..
        '}'
        ngx.say(error_response)
        -- Return response body in nginx log for debugging purposes
        ngx.log(ngx.ERR, error_response)
        return ngx.exit(ngx.status)
    end
end

function file_transfer_endpoints.return_upload_success()

    -- Nginx big upload module adds headers with checksum and temporary file name to its response.
    -- We don't want to return them to the client.
    -- FIXME: Setting it to an empty string does not remove the headers. For now we set it to a
    -- single space to work around this but we should really just find a way to remove those headers.
    ngx.header["X-SHA1"]       = " "
    ngx.header["X-Session-Id"] = " "
    ngx.header.content_type    = "application/json; charset=utf-8"
    successful_response        = '{"message": "File was successfully uploaded"}'
    ngx.say(successful_response)
    ngx.log(ngx.NOTICE, successful_response)
end

return file_transfer_endpoints
