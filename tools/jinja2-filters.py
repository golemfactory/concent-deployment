import base64

class SecretIsNotString(Exception):
    pass

class NotSupportedDataType(Exception):
    pass

def filter_b64decode(secret_value, data_type = "string"):
    if not isinstance(secret_value, str):
        raise SecretIsNotString
    if data_type == "string":
        # The code above return exception:
        # binascii.Error if secret_value is not correct base64 data
        # UnicodeDecodeError if you try decode bytes to utf-8 format
        return base64.b64decode(secret_value).decode("utf-8")
    if data_type == "bytes":
        return base64.b64decode(secret_value)
    raise NotSupportedDataType
