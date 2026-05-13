import * as functions from 'firebase-functions';
import { CloudTasksClient } from '@google-cloud/tasks';
import { ExtendCloudTaskScheduler } from './extend_cloud_task_scheduler';
import { ExtendCloudTaskSchedulerRequest } from '../../types';

const DEPLOY_TASK_CUTOFF_DAYS = 28;

class ScheduledFunctions {
  private _client?: CloudTasksClient;

  private get client(): CloudTasksClient {
    if (!this._client) {
      this._client = new CloudTasksClient();
    }
    return this._client;
  }

  private get parentPath(): string {
    const projectId = functions.config().app?.project_id as string;
    return this.client.queuePath(projectId, 'us-east4', 'scheduled-functions');
  }

  async enqueueCall(
    functionName: string,
    encodedJsonPayload: string,
    scheduledTime: Date
  ): Promise<void> {
    const cutoffTime = new Date();
    cutoffTime.setDate(cutoffTime.getDate() + DEPLOY_TASK_CUTOFF_DAYS);

    if (scheduledTime > cutoffTime) {
      console.log('Rescheduling task since its after cutoff time');
      const req: ExtendCloudTaskSchedulerRequest = {
        scheduledTime: scheduledTime,
        functionName,
        payload: encodedJsonPayload,
      };
      await new ExtendCloudTaskScheduler().schedule(req, cutoffTime);
    } else {
      console.log('Enqueuing task to call its function');
      await this._enqueueDirectly(functionName, encodedJsonPayload, scheduledTime);
    }
  }

  private async _enqueueDirectly(
    functionName: string,
    encodedJson: string,
    scheduledTime: Date
  ): Promise<void> {
    const urlPrefix = functions.config().app?.functions_url_prefix as string;
    const body = Buffer.from(encodedJson).toString('base64');

    await this.client.createTask({
      parent: this.parentPath,
      task: {
        httpRequest: {
          url: `${urlPrefix}/${functionName}`,
          httpMethod: 'POST' as const,
          body,
          headers: { 'Content-Type': 'application/json' },
        },
        scheduleTime: {
          seconds: Math.round(scheduledTime.getTime() / 1000),
        },
      },
    });
  }
}

export const scheduledFunctions = new ScheduledFunctions();
