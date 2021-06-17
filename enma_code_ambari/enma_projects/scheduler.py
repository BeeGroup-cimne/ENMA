from djcelery.schedulers import DatabaseScheduler
from djcelery.models import PeriodicTask
from celery.utils.log import get_logger

import json
import pickle
import traceback
from dateutil.relativedelta import relativedelta

logger = get_logger(__name__)


class MyScheduler(DatabaseScheduler):

    def __init__(self, *args, **kwargs):
        super(MyScheduler, self).__init__(*args, **kwargs)

    def maybe_due(self, entry, publisher=None):
        is_due, next_time_to_run = entry.is_due()

        if is_due:
            logger.info('myScheduler: Sending due task %s (%s)', entry.name, entry.task)
            try:
                result = self.apply_async(entry, publisher=publisher)
                logger.debug('%s self.apply_async correctly executed', entry.task)
                self.maybe_update_args(entry)
                logger.debug('%s args updated', entry.task)
            except Exception as exc:
                logger.error('Message Error: %s\n%s',
                             exc, traceback.format_stack(), exc_info=True)
            else:
                logger.debug('%s sent. id->%s', entry.task, result.id)
        return next_time_to_run

    def reserve(self, entry):
        new_entry = self.schedule[entry.name] = next(entry)
        try:
            new_entry.args = [pickle.loads(new_entry.args[0]['pickle'])]
        except:
            pass
        return new_entry

    def maybe_update_args(self, entry):
        ptask = PeriodicTask.objects.filter(name=entry.name)[0]
        logger.debug('Updating args for ptask %r' % ptask.id)
        try:
            args = pickle.loads(entry.args[0]['pickle'])
        except Exception as e:
            return
        update_params = args.get('update_params')
        if update_params:
            for param in update_params.split(','):
                logger.debug('Updating "%s" parameter' % param)
                logger.debug('args provided to do so: %s' % args)
                updated = self._update_ts_arg(param, args)
                if updated:
                    logger.debug('Updating "%s" with value: %s' % (args[param], updated))
                    args[param] = updated

        ptask.args = json.dumps([{'pickle': pickle.dumps(args)}])
        try:
            ptask.save()
        except Exception as e:
            logger.error('Error saving periodic task: %s' % e)

    def _update_ts_arg(self, key, args):
        res = None
        if args['periodicity'] == 'monthly':
            # res = args[key] + relativedelta(months=1)
            # add second to undo datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0) - relativedelta(seconds=1) on task schedule save
            # and redo it after adding month
            res = args[key] + relativedelta(seconds=1) + relativedelta(months=1) - relativedelta(seconds=1)
        elif args['periodicity'] == 'weekly':
            res = args[key] + relativedelta(days=7)

        return res