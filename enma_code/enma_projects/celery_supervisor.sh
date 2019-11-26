#! /bin/bash
export C_FORCE_ROOT=True
export DJANGO_SETTINGS_MODULE=celeryconfig
export PYTHONPATH=""
exec celery worker --app=celery_backend:app -l debug