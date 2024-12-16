import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/self/my_discussions_page_provider.dart';
import 'package:junto/common_widgets/discussion_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

class ConversationsTab extends StatefulWidget {
  const ConversationsTab._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => MyDiscussionsPageProvider(),
      child: ConversationsTab._(),
    );
  }

  @override
  _ConversationsTabState createState() => _ConversationsTabState();
}

class _ConversationsTabState extends State<ConversationsTab> {
  @override
  void initState() {
    context.read<MyDiscussionsPageProvider>().initialize();

    super.initState();
  }

  Widget _buildDiscussionsList(Stream<List<Discussion>> discussionStream) {
    return JuntoStreamBuilder<List<Discussion>>(
      entryFrom: '_ConversationsTabState._buildDiscussionsList',
      stream: discussionStream,
      height: 100,
      builder: (_, discussions) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            if (discussions!.isEmpty) Text('No events found', style: AppTextStyle.body),
            for (final discussion in discussions.take(40)) ...[
              DiscussionButton(key: Key('discussion-${discussion.id}'), discussion: discussion),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildUpcomingDiscussions() {
    return [
      SizedBox(height: 40),
      ConstrainedBody(
        child: Align(
          alignment: Alignment.centerLeft,
          child: JuntoText(
            'UPCOMING',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      ConstrainedBody(
        child: _buildDiscussionsList(
            Provider.of<MyDiscussionsPageProvider>(context).upcomingDiscussions),
      ),
    ];
  }

  List<Widget> _buildPastDiscussions() {
    return [
      SizedBox(height: 40),
      ConstrainedBody(
        child: Align(
          alignment: Alignment.centerLeft,
          child: JuntoText(
            'HISTORY',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      ConstrainedBody(
        child: _buildDiscussionsList(
            Provider.of<MyDiscussionsPageProvider>(context).previousDiscussions),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._buildUpcomingDiscussions(),
        ..._buildPastDiscussions(),
      ],
    );
  }
}
