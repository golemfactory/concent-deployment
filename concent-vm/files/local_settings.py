from .development import *

DATABASES['control']['HOST']     = 'localhost'
DATABASES['default']['HOST']     = 'localhost'
DATABASES['storage']['HOST']     = 'localhost'

STORAGE_CLUSTER_ADDRESS = 'http://172.40.2.3:8001/'
PAYMENT_BACKEND = 'core.payments.backends.sci_backend'

ALLOWED_HOSTS = [
    "172.40.2.3",
    "127.0.0.1",
]

from .extra_settings import *
