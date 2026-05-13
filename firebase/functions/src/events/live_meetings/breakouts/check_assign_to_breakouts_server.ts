import { OnRequestMethod } from '../../../on_request_method';
import { CheckAssignToBreakouts } from './check_assign_to_breakouts';

interface CheckAssignToBreakoutsRequest {
  eventPath: string;
  breakoutSessionId: string;
}

export class CheckAssignToBreakoutsServer extends OnRequestMethod<CheckAssignToBreakoutsRequest> {
  constructor() {
    super(
      'CheckAssignToBreakoutsServer',
      (jsonMap) => jsonMap as CheckAssignToBreakoutsRequest,
      { runWithOptions: { timeoutSeconds: 240, memory: '4GB', minInstances: 0 } }
    );
  }

  async action(request: CheckAssignToBreakoutsRequest): Promise<string> {
    await new CheckAssignToBreakouts().checkAssignToBreakouts(request, 'server');
    return '';
  }
}
