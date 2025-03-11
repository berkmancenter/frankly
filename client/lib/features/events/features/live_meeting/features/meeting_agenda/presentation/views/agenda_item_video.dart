import 'package:client/features/events/features/live_meeting/features/meeting_agenda/utils/agenda_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/url_video_widget.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_video_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/vimeo_video_widget.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/events/event.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

enum AgendaItemVideoTabType {
  /// Locally picked video from a file.
  local,

  /// Youtube URL.
  youtube,

  /// Vimeo URL.
  vimeo,

  /// URL from unknown source.
  url,
}

class AgendaItemVideo extends StatefulWidget {
  final bool isEditMode;
  final AgendaItemVideoData agendaItemVideoData;
  final void Function(AgendaItemVideoData) onChanged;

  const AgendaItemVideo({
    Key? key,
    required this.isEditMode,
    required this.agendaItemVideoData,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AgendaItemVideoState createState() => _AgendaItemVideoState();
}

class _AgendaItemVideoState extends State<AgendaItemVideo>
    with TickerProviderStateMixin
    implements AgendaItemVideoView {
  late List<AgendaItemVideoTabType> _agendaItemVideoTabTypes;
  late TextEditingController _textEditingController;
  late TabController _tabController;
  YoutubePlayerController? _youtubePlayerController;
  late VideoPlayerController _videoController;

  late AgendaItemVideoModel _model;
  late AgendaItemVideoPresenter _presenter;

  void _init() {
    _model = AgendaItemVideoModel(
      widget.isEditMode,
      widget.agendaItemVideoData,
      widget.onChanged,
    );
    _presenter = AgendaItemVideoPresenter(context, this, _model);
    _presenter.init();

    // Only temporarily made solution. Once we get rid of the flag, we should only read from
    // AgendaItemVideoTabType.values.
    _agendaItemVideoTabTypes = _presenter.isMultipleVideoTypesEnabled()
        ? AgendaItemVideoTabType.values
        : [AgendaItemVideoTabType.local, AgendaItemVideoTabType.url];

    final String url = _model.agendaItemVideoData.url;
    _updateTextInController(url);

    _videoController = VideoPlayerController.network(url);
    final initialIndex = _presenter.getInitialIndex();
    _tabController = TabController(
      initialIndex: initialIndex,
      length: _agendaItemVideoTabTypes.length,
      vsync: this,
    );
  }

  void _updateTextInController(String text) {
    _textEditingController.text = text;
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  void initState() {
    super.initState();

    _textEditingController =
        TextEditingController(text: widget.agendaItemVideoData.url);
    _init();
  }

  @override
  void didUpdateWidget(AgendaItemVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEditMode != widget.isEditMode ||
        oldWidget.agendaItemVideoData != widget.agendaItemVideoData) {
      _init();
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _youtubePlayerController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kMaxHeight = 500.0;
    final videoUrl = _presenter.getVideoUrl();
    final isMultipleVideoTypesEnabled =
        _presenter.isMultipleVideoTypesEnabled();

    if (_model.isEditMode) {
      return Column(
        children: [
          CustomTextField(
            initialValue: _model.agendaItemVideoData.title,
            labelText: 'Title',
            hintText: 'Enter Video title',
            maxLines: 1,
            maxLength: agendaTitleCharactersLength,
            counterStyle: AppTextStyle.bodySmall.copyWith(
              color: AppColor.darkBlue,
            ),
            onChanged: (value) => _presenter.updateVideoTitle(value),
          ),
          SizedBox(height: 40),
          Row(
            children: List.generate(_agendaItemVideoTabTypes.length, (index) {
              final agendaItemVideoTabType = _agendaItemVideoTabTypes[index];
              final isSelected =
                  _model.agendaItemVideoTabType == agendaItemVideoTabType;
              final color = isSelected ? AppColor.darkBlue : AppColor.gray4;
              final tabName = _presenter.getTabName(agendaItemVideoTabType);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _presenter.updateVideoType(agendaItemVideoTabType);
                      _tabController.animateTo(index);
                    },
                    child: Column(
                      children: [
                        Text(
                          tabName,
                          style: AppTextStyle.eyebrow.copyWith(color: color),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(height: 4, color: color),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: kMaxHeight),
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: isMultipleVideoTypesEnabled
                  ? [
                      _buildLocalVideo(videoUrl),
                      _buildYoutube(videoUrl),
                      _buildVimeo(videoUrl),
                      _buildUrlVideo(videoUrl),
                    ]
                  : [
                      _buildLocalVideo(videoUrl),
                      _buildUrlVideo(videoUrl),
                    ],
            ),
          ),
        ],
      );
    } else {
      return _buildInitializedVideo(videoUrl);
    }
  }

  @override
  void updateView() {
    setState(() {});
  }

  Widget _buildVideoPicker(String text) {
    return ActionButton(
      color: AppColor.darkBlue,
      textColor: AppColor.brightGreen,
      text: text,
      onPressed: () async {
        final url =
            await GetIt.instance<MediaHelperService>().pickVideoViaCloudinary();
        if (url != null) {
          _updateTextInController(url);
          _presenter.updateVideoUrl(url);
        }
      },
    );
  }

  Widget _buildInitializedVideo(String videoUrl) {
    switch (_model.agendaItemVideoData.type) {
      case AgendaItemVideoType.youtube:
        final youtubeVideoId = _presenter.getYoutubeVideoId(videoUrl);
        if (youtubeVideoId != null) {
          return Builder(
            builder: (context) {
              _youtubePlayerController = YoutubePlayerController.fromVideoId(
                videoId: youtubeVideoId,
                params: YoutubePlayerParams(showControls: true),
              );

              return YoutubePlayer(
                controller: _youtubePlayerController!,
                aspectRatio: 16 / 9,
              );
            },
          );
        } else {
          return Text('Sorry, youtube video lookup failed.');
        }
      case AgendaItemVideoType.vimeo:
        final vimeoVideoId = _presenter.getVimeoVideoId(videoUrl);

        if (vimeoVideoId != null) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: VimeoVideoWidget(vimeoId: vimeoVideoId),
          );
        } else {
          return Text('Sorry, vimeo video lookup failed.');
        }
      case AgendaItemVideoType.url:
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: UrlVideoWidget(
            playbackUrl: videoUrl,
            autoplay: false,
          ),
        );
    }
  }

  Widget _buildLocalVideo(String videoUrl) {
    final isVideoUploaded = _presenter.isValidVideo();

    if (isVideoUploaded) {
      return UrlVideoWidget(playbackUrl: videoUrl, autoplay: false);
    } else {
      return Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Container(
              color: AppColor.gray6,
              child: Center(
                child: _buildVideoPicker('Upload Video'),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildYoutube(String videoUrl) {
    final youtubeVideoId = _presenter.getYoutubeVideoId(videoUrl);

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                padding: EdgeInsets.zero,
                controller: _textEditingController,
                labelText: 'YouTube URL',
                maxLines: null,
                textStyle:
                    AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                hintStyle:
                    AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                onChanged: (value) => _presenter.updateVideoUrl(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (youtubeVideoId != null)
          Builder(
            builder: (context) {
              _youtubePlayerController = YoutubePlayerController.fromVideoId(
                videoId: youtubeVideoId,
                params: YoutubePlayerParams(showControls: true),
              );

              return YoutubePlayer(
                controller: _youtubePlayerController!,
                aspectRatio: 16 / 9,
              );
            },
          )
        else
          Expanded(
            child: Container(
              color: AppColor.gray6,
              child: Center(
                child: ProxiedImage(
                  null,
                  asset: AppAsset('media/youtube.png'),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVimeo(String videoUrl) {
    final vimeoVideoId = _presenter.getVimeoVideoId(videoUrl);

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                padding: EdgeInsets.zero,
                controller: _textEditingController,
                labelText: 'Vimeo URL',
                maxLines: null,
                textStyle:
                    AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                hintStyle:
                    AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                onChanged: (value) => _presenter.updateVideoUrl(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (vimeoVideoId != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VimeoVideoWidget(vimeoId: vimeoVideoId),
          )
        else
          Expanded(
            child: Container(
              color: AppColor.gray6,
              child: Center(
                child: ProxiedImage(
                  null,
                  asset: AppAsset('media/vimeo.png'),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUrlVideo(String videoUrl) {
    final isValidVideo = _model.agendaItemVideoData.url.isNotEmpty;

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                padding: EdgeInsets.zero,
                controller: _textEditingController,
                labelText: 'Link must be MP4',
                maxLines: null,
                textStyle:
                    AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                hintStyle:
                    AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                onChanged: (value) => _presenter.updateVideoUrl(value),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (isValidVideo)
          Expanded(
            child: UrlVideoWidget(
              playbackUrl: videoUrl,
              autoplay: false,
            ),
          )
        else
          Expanded(
            child: Container(
              color: AppColor.gray6,
              child: Center(
                child: ProxiedImage(
                  null,
                  asset: AppAsset('media/social-link-grey.png'),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
