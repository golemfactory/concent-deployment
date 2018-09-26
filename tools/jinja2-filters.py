from base64 import b64decode

class NotAString(Exception):
    pass

class NotSupportedDataType(Exception):
    pass

def filter_b64decode(encoded_value, return_type = "string"):
    if not isinstance(encoded_value, str):
        raise NotAString
    if return_type == "string":
        # The code above return exception:
        # binascii.Error if encoded_value is not correct base64 data
        # UnicodeDecodeError if you try decode bytes to utf-8 format
        return b64decode(encoded_value).decode("utf-8")
    if return_type == "bytes":
        return b64decode(encoded_value)
    else:
        raise NotSupportedDataType
