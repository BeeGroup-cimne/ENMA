from kombu import Exchange, Queue
from json import load


CELERY_TASK_RESULT_EXPIRES = 3600
CELERY_RESULT_PERSISTENT = False
CELERY_TASK_SERIALIZER = 'pickle'
CELERY_RESULT_SERIALIZER = 'pickle'
CELERY_TIMEZONE = 'Europe/Madrid'
TIME_ZONE = 'Europe/Madrid'
CELERY_ENABLE_UTC = False
CELERY_QUEUES = (
    Queue('modules',  Exchange('modules', type='direct')),
    Queue('etl',  Exchange('etl', type='direct')),
    # we create a direct exchange so we can send all tasks to a single queue and routing them by name
)
#CELERY_IGNORE_RESULT = True,
CELERY_CHORD_PROPAGATES = True
CELERY_DISABLE_RATE_LIMITS = True
CELERYD_LOG_COLOR = False






# environment dependent configuration
f = open('envconfig.json')
config = load(f)
f.close()
if 'vhost' in config['broker']:
    BROKER_URL = 'amqp://%s:%s@%s:%s/%s' % (config['broker']['user'], config['broker']['password'], config['broker']['host'], config['broker']['port'], config['broker']['vhost'])
else:
    BROKER_URL = 'amqp://%s@%s:%s//' % (config['broker']['user'], config['broker']['host'], config['broker']['port'])
CELERY_RESULT_BACKEND = 'amqp'



DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '',
        'USER': '',
        'PASSWORD': '',
        'HOST': '',   # Or an IP Address that your DB is hosted on
        'PORT': '3306',
    }
}


INSTALLED_APPS = ('djcelery', )

CELERYBEAT_SCHEDULER = "scheduler.MyScheduler"

SECRET_KEY = '$b9$@ewh1iqkb^a+s_+5#$i7)n*ao^y$2%ivamz_i!$p5$3nti'