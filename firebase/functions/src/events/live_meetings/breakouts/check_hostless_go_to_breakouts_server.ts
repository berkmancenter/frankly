import { OnRequestMethod } from '../../../on_request_method';
import { CheckHostlessGoToBreakouts } from './check_hostless_go_to_breakouts';

interface CheckHostlessGoToBreakoutsRequest {
  eventPath: string;
}

export class CheckHostlessGoToBreakoutsServer extends OnRequestMethod<CheckHostlessGoToBreakoutsRequest> {
  constructor() {
    super(
      'CheckHostlessGoToBreakoutsServer',
      (jsonMap) => jsonMap as CheckHostlessGoToBreakoutsRequest,
      { runWithOptions: { timeoutSeconds: 240, memory: '4GB' } }
    );
  }

  async action(request: CheckHostlessGoToBreakoutsRequest): Promise<string> {
    await new CheckHostlessGoToBreakouts().checkHostlessGoToBreakouts(request, 'server');
    return '';
  }
}
