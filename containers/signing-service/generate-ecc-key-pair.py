from golem_messages import ECCx
from base64 import b64encode

ecc = ECCx(None)

signing_service_public_key=b64encode(ecc.raw_pubkey).decode('utf-8')
signing_service_private_key=b64encode(ecc.raw_privkey).decode('utf-8')

print("SIGNING_SERVICE_PUBLIC_KEY  = {}".format(signing_service_public_key))
print("SIGNING_SERVICE_PRIVATE_KEY = {}".format(signing_service_private_key))
