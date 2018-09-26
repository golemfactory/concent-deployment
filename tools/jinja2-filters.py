from base64 import b64decode

class NotAString(Exception):
    pass

class NotSupportedDataType(Exception):
    pass

def filter_b64decode(encoded_value, return_type = "string"):
    if not isinstance(encoded_value, str):
        raise NotAString
    if return_type == "string":
        # If the input is invalid, decoding can result in the following exceptions:
        # - binascii.Error     - if the input is not base64 encoded
        # - UnicodeDecodeError - if the encoded value is not a valid UTF-8 string
        return b64decode(encoded_value).decode("utf-8")
    if return_type == "bytes":
        return b64decode(encoded_value)
    else:
        raise NotSupportedDataType
