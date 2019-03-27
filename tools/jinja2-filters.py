from base64 import b64decode

class NotAString(Exception):
    pass

class NotADict(Exception):
    pass

class KeyNotFound(Exception):
    pass

class UnsupportedDataType(Exception):
    pass

def filter_b64decode(encoded_value, return_type="string"):
    if not isinstance(encoded_value, str):
        raise NotAString("The encoded value is not a string")
    if return_type == "string":
        # If the input is invalid, decoding can result in the following exceptions:
        # - binascii.Error     - if the input is not base64 encoded
        # - UnicodeDecodeError - if the encoded value is not a valid UTF-8 string
        return b64decode(encoded_value, validate=True).decode("utf-8")
    if return_type == "bytes":
        return b64decode(encoded_value, validate=True)
    else:
        raise UnsupportedDataType("The encoded value is an unsupported data type")

def filter_chained_get(dictionary, keys):
    if not isinstance(dictionary, dict):
        raise NotADict("The dictionary variable is not a dict")
    if not isinstance(keys, str):
        raise NotAString("The keys variable is not a string")

    key_list = keys.split('.')
    nested_dictionary = dictionary
    for key in key_list:
        if nested_dictionary is None:
            return None
        if not isinstance(nested_dictionary, dict):
            raise NotADict(f"{key} can not be found, because {nested_dictionary} is not a dict")
        if key in nested_dictionary:
            nested_dictionary = nested_dictionary[key]
        else:
            return None
    return nested_dictionary
