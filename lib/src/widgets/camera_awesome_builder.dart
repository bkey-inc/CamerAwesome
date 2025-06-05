import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart' as CameraAwesome;
import 'package:camerawesome/pigeon.dart';
import 'package:camerawesome/src/orchestrator/camera_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This is the builder for your camera interface
/// Using the [state] you can do anything you need without having to think about the camera flow
/// On app start we are in [PreparingCameraState]
/// Then depending on the initialCaptureMode you set you will be [PhotoCameraState] or [VideoCameraState]
/// Starting a video will push a [VideoRecordingCameraState]
/// Stopping the video will push back the [VideoCameraState]
/// ----
/// If you need to call specific function for a state use the 'when' function.
typedef CameraLayoutBuilder = Widget Function(
  CameraAwesome.CameraState state,

  /// [previewSize] not clipped
  //PreviewSize previewSize,

  /// [previewRect] size might be different than [previewSize] if it has been
  /// clipped. It is often clipped in 1:1 ratio. Use it to show elements
  /// relative to the preview (inside or outside for instance)
  //Rect previewRect,

  CameraAwesome.Preview preview,
);

/// Callback when a video or photo has been saved and user click on thumbnail
typedef OnMediaTap = Function(CameraAwesome.MediaCapture mediaCapture)?;

/// Used to set a permission result callback
typedef OnPermissionsResult = void Function(bool result);

/// Listener for picture or video capture event
typedef OnMediaCaptureEvent = void Function(
    CameraAwesome.MediaCapture mediaCapture);

/// Analysis image stream listener
/// The Preview object will help you to convert a point from the preview to the
/// to your screen
typedef OnImageForAnalysis = Future Function(
  CameraAwesome.AnalysisImage image,
);

/// This is the entry point of the CameraAwesome plugin
/// You can either
/// - build your custom layout
/// or
/// - use our built in interface
/// with the awesome factory
class CameraAwesomeBuilder extends StatefulWidget {
  /// Which sensors you want to use
  final CameraAwesome.SensorConfig sensorConfig;

  /// check this for more details
  /// https://api.flutter.dev/flutter/painting/BoxFit.html
  // one of fitWidth, fitHeight, contain, cover
  // currently only work for Android, this do nothing on iOS
  final CameraAwesome.CameraPreviewFit previewFit;

  /// Enable physical button (volume +/-) to take photo or record video
  final bool enablePhysicalButton;

  /// Path builders when taking photos or recording videos
  final CameraAwesome.SaveConfig? saveConfig;

  /// Called when the preview of the last captured media is tapped
  final OnMediaTap onMediaTap;

  // Widgets
  final Widget? progressIndicator;

  /// UI Builder
  final CameraLayoutBuilder builder;

  final OnImageForAnalysis? onImageForAnalysis;

  /// only for Android
  final CameraAwesome.AnalysisConfig? imageAnalysisConfig;

  /// Useful for drawing things based on AI Analysis above the CameraPreview for instance
  final CameraLayoutBuilder? previewDecoratorBuilder;

  final CameraAwesome.OnPreviewTap Function(CameraAwesome.CameraState)?
      onPreviewTapBuilder;
  final CameraAwesome.OnPreviewScale Function(CameraAwesome.CameraState)?
      onPreviewScaleBuilder;

  /// Theme of the camera UI, used in the built-in interface.
  ///
  /// You can also use it in your own UI with [AwesomeThemeProvider].
  /// You might need to wrap your UI in a [Builder] to get a [context].
  final CameraAwesome.AwesomeTheme theme;

  /// Add padding to the preview to adjust where you want to position it.
  /// See also [previewAlignment].
  final EdgeInsets previewPadding;

  /// Set alignment of the preview to adjust its position.
  /// See also [previewPadding].
  final Alignment previewAlignment;

  /// Set it to true to show a Preview of the camera, false if you only want to
  /// do image analysis
  final bool showPreview;

  final CameraAwesome.PictureInPictureConfigBuilder?
      pictureInPictureConfigBuilder;

  /// THe default filter to use when the camera is started.
  final CameraAwesome.AwesomeFilter? defaultFilter;

  /// List of filters to show in the built-in interface.
  /// (default: [awesomePresetFiltersList])
  /// Push null to hide the filter button
  final List<CameraAwesome.AwesomeFilter>? availableFilters;

  /// Triggered when a photo or video has been saved
  /// You can use it to do whatever you want once a media has been saved
  final OnMediaCaptureEvent? onMediaCaptureEvent;

  const CameraAwesomeBuilder._({
    required this.sensorConfig,
    required this.enablePhysicalButton,
    required this.progressIndicator,
    required this.saveConfig,
    required this.onMediaTap,
    required this.builder,
    required this.previewFit,
    required this.defaultFilter,
    this.onImageForAnalysis,
    this.imageAnalysisConfig,
    this.onPreviewTapBuilder,
    this.onPreviewScaleBuilder,
    this.previewDecoratorBuilder,
    required this.theme,
    this.previewPadding = EdgeInsets.zero,
    this.previewAlignment = Alignment.center,
    this.showPreview = true,
    required this.pictureInPictureConfigBuilder,
    this.availableFilters,
    this.onMediaCaptureEvent,
  });

  /// Use the camera with the built-in interface.
  ///
  /// You need to provide a [SaveConfig] to define if you want to take
  /// photos, videos or both and where to save them.
  ///
  /// You can initiate the camera with a few parameters through the [SensorConfig]:
  /// - which [sensors] to use ([front] or [back])
  /// - which [flashMode] to use
  /// - how much zoom you want (0.0 = no zoom, 1.0 = max zoom)
  ///
  /// If you want to customize the UI of the camera, you have several options:
  /// - use a [progressIndicator] and define what to do when the preview of the
  /// last media taken is tapped thanks to [onMediaTap]
  /// - use [topActionsBuilder], [bottomActionsBuilder], and
  /// [middleContentBuilder] which let you build entirely the UI similarly to
  /// how the built-in UI is done. Check [AwesomeCameraLayout] for more details.
  /// - build your UI entirely thanks to the [custom] constructor.
  ///
  /// If you want to do image analysis (for AI for instance), you can set the
  /// [imageAnaysisConfig] and listen to the stream of images with
  /// [onImageForAnalysis].
  CameraAwesomeBuilder.awesome(
      {CameraAwesome.SensorConfig? sensorConfig,
      bool enablePhysicalButton = false,
      Widget? progressIndicator,
      required CameraAwesome.SaveConfig saveConfig,
      Function(CameraAwesome.MediaCapture)? onMediaTap,
      OnImageForAnalysis? onImageForAnalysis,
      CameraAwesome.AnalysisConfig? imageAnalysisConfig,
      CameraAwesome.OnPreviewTap Function(CameraAwesome.CameraState)? onPreviewTapBuilder,
      CameraAwesome.OnPreviewScale Function(CameraAwesome.CameraState)? onPreviewScaleBuilder,
      CameraAwesome.CameraPreviewFit? previewFit,
      CameraLayoutBuilder? previewDecoratorBuilder,
      CameraAwesome.AwesomeTheme? theme,
      Widget Function(CameraAwesome.CameraState state)? topActionsBuilder,
      Widget Function(CameraAwesome.CameraState state)? bottomActionsBuilder,
      Widget Function(CameraAwesome.CameraState state)? middleContentBuilder,
      EdgeInsets previewPadding = EdgeInsets.zero,
      Alignment previewAlignment = Alignment.center,
      CameraAwesome.PictureInPictureConfigBuilder?
          pictureInPictureConfigBuilder,
      CameraAwesome.AwesomeFilter? defaultFilter,
      List<CameraAwesome.AwesomeFilter>? availableFilters,
      OnMediaCaptureEvent? onMediaCaptureEvent})
      : this._(
          sensorConfig: sensorConfig ??
              CameraAwesome.SensorConfig.single(
                sensor: CameraAwesome.Sensor.position(
                    CameraAwesome.SensorPosition.back),
              ),
          enablePhysicalButton: enablePhysicalButton,
          progressIndicator: progressIndicator,
          builder: (cameraModeState, preview) {
            return CameraAwesome.AwesomeCameraLayout(
              state: cameraModeState,
              onMediaTap: onMediaTap,
              topActions: topActionsBuilder?.call(cameraModeState),
              bottomActions: bottomActionsBuilder?.call(cameraModeState),
              middleContent: middleContentBuilder?.call(cameraModeState),
            );
          },
          saveConfig: saveConfig,
          onMediaTap: onMediaTap,
          onImageForAnalysis: onImageForAnalysis,
          imageAnalysisConfig: imageAnalysisConfig,
          onPreviewTapBuilder: onPreviewTapBuilder,
          onPreviewScaleBuilder: onPreviewScaleBuilder,
          previewFit: previewFit ?? CameraAwesome.CameraPreviewFit.cover,
          previewDecoratorBuilder: previewDecoratorBuilder,
          theme: theme ?? CameraAwesome.AwesomeTheme(),
          previewPadding: previewPadding,
          previewAlignment: previewAlignment,
          pictureInPictureConfigBuilder: pictureInPictureConfigBuilder,
          defaultFilter: defaultFilter,
          availableFilters:
              availableFilters ?? CameraAwesome.awesomePresetFiltersList,
          onMediaCaptureEvent: onMediaCaptureEvent,
        );

  /// 🚧 Experimental
  ///
  /// Documentation on its way, API might change
  CameraAwesomeBuilder.custom({
    CameraAwesome.SensorConfig? sensorConfig,
    bool mirrorFrontCamera = false,
    bool enablePhysicalButton = false,
    Widget? progressIndicator,
    required CameraLayoutBuilder builder,
    required CameraAwesome.SaveConfig saveConfig,
    CameraAwesome.AwesomeFilter? filter,
    OnImageForAnalysis? onImageForAnalysis,
    CameraAwesome.AnalysisConfig? imageAnalysisConfig,
    CameraAwesome.OnPreviewTap Function(CameraAwesome.CameraState)? onPreviewTapBuilder,
    CameraAwesome.OnPreviewScale Function(CameraAwesome.CameraState)? onPreviewScaleBuilder,
    CameraAwesome.CameraPreviewFit? previewFit,
    CameraAwesome.AwesomeTheme? theme,
    EdgeInsets previewPadding = EdgeInsets.zero,
    Alignment previewAlignment = Alignment.center,
    CameraAwesome.PictureInPictureConfigBuilder? pictureInPictureConfigBuilder,
    List<CameraAwesome.AwesomeFilter>? filters,
    OnMediaCaptureEvent? onMediaCaptureEvent,
  }) : this._(
          sensorConfig: sensorConfig ??
              CameraAwesome.SensorConfig.single(
                sensor: CameraAwesome.Sensor.position(
                    CameraAwesome.SensorPosition.back),
              ),
          enablePhysicalButton: enablePhysicalButton,
          progressIndicator: progressIndicator,
          builder: builder,
          saveConfig: saveConfig,
          onMediaTap: null,
          defaultFilter: filter,
          onImageForAnalysis: onImageForAnalysis,
          imageAnalysisConfig: imageAnalysisConfig,
          onPreviewTapBuilder: onPreviewTapBuilder,
          onPreviewScaleBuilder: onPreviewScaleBuilder,
          previewFit: previewFit ?? CameraAwesome.CameraPreviewFit.cover,
          previewDecoratorBuilder: null,
          theme: theme ?? CameraAwesome.AwesomeTheme(),
          previewPadding: previewPadding,
          previewAlignment: previewAlignment,
          pictureInPictureConfigBuilder: pictureInPictureConfigBuilder,
          availableFilters: filters,
          onMediaCaptureEvent: onMediaCaptureEvent,
        );

  /// Use this constructor when you don't want to take pictures or record videos.
  /// You can still do image analysis.
  CameraAwesomeBuilder.previewOnly({
    CameraAwesome.SensorConfig? sensorConfig,
    Widget? progressIndicator,
    required CameraLayoutBuilder builder,
    CameraAwesome.AwesomeFilter? filter,
    OnImageForAnalysis? onImageForAnalysis,
    CameraAwesome.AnalysisConfig? imageAnalysisConfig,
    CameraAwesome.OnPreviewTap Function(CameraAwesome.CameraState)? onPreviewTapBuilder,
    CameraAwesome.OnPreviewScale Function(CameraAwesome.CameraState)? onPreviewScaleBuilder,
    CameraAwesome.CameraPreviewFit? previewFit,
    EdgeInsets previewPadding = EdgeInsets.zero,
    Alignment previewAlignment = Alignment.center,
    CameraAwesome.PictureInPictureConfigBuilder? pictureInPictureConfigBuilder,
  }) : this._(
          sensorConfig: sensorConfig ??
              CameraAwesome.SensorConfig.single(
                  sensor: CameraAwesome.Sensor.position(
                      CameraAwesome.SensorPosition.back)),
          enablePhysicalButton: false,
          progressIndicator: progressIndicator,
          builder: builder,
          saveConfig: null,
          onMediaTap: null,
          defaultFilter: filter,
          onImageForAnalysis: onImageForAnalysis,
          imageAnalysisConfig: imageAnalysisConfig,
          onPreviewTapBuilder: onPreviewTapBuilder,
          onPreviewScaleBuilder: onPreviewScaleBuilder,
          previewFit: previewFit ?? CameraAwesome.CameraPreviewFit.cover,
          previewDecoratorBuilder: null,
          theme: CameraAwesome.AwesomeTheme(),
          previewPadding: previewPadding,
          previewAlignment: previewAlignment,
          pictureInPictureConfigBuilder: pictureInPictureConfigBuilder,
        );

  /// Use this constructor when you only want to do image analysis.
  ///
  /// E.g.: QR code detection, barcode detection, face detection, etc.
  ///
  /// You can't take pictures or record videos and the preview won't be displayed.
  /// You may still show the image from the analysis by converting it to JPEG
  /// and  displaying that JPEG image.
  CameraAwesomeBuilder.analysisOnly({
    CameraAwesome.SensorConfig? sensorConfig,
    CameraAwesome.CameraAspectRatios aspectRatio =
        CameraAwesome.CameraAspectRatios.ratio_4_3,
    Widget? progressIndicator,
    required CameraLayoutBuilder builder,
    required OnImageForAnalysis onImageForAnalysis,
    CameraAwesome.AnalysisConfig? imageAnalysisConfig,
  }) : this._(
          sensorConfig: sensorConfig ??
              CameraAwesome.SensorConfig.single(
                  sensor: CameraAwesome.Sensor.position(
                      CameraAwesome.SensorPosition.back)),
          enablePhysicalButton: false,
          progressIndicator: progressIndicator,
          builder: builder,
          saveConfig: null,
          onMediaTap: null,
          defaultFilter: null,
          onImageForAnalysis: onImageForAnalysis,
          imageAnalysisConfig: imageAnalysisConfig,
          onPreviewTapBuilder: null,
          onPreviewScaleBuilder: null,
          previewFit: CameraAwesome.CameraPreviewFit.cover,
          previewDecoratorBuilder: null,
          theme: CameraAwesome.AwesomeTheme(),
          previewPadding: EdgeInsets.zero,
          previewAlignment: Alignment.center,
          showPreview: false,
          pictureInPictureConfigBuilder: null,
        );

  @override
  State<StatefulWidget> createState() {
    return _CameraWidgetBuilder();
  }
}

class _CameraWidgetBuilder extends State<CameraAwesomeBuilder>
    with WidgetsBindingObserver {
  late CameraContext _cameraContext;
  final _cameraPreviewKey =
      GlobalKey<CameraAwesome.AwesomeCameraPreviewState>();
  StreamSubscription<CameraAwesome.MediaCapture?>? _captureStateListener;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraContext.dispose();
    _captureStateListener?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CameraAwesomeBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _cameraContext //
            .state
            .when(onVideoRecordingMode: (mode) => mode.stopRecording());
        break;
      case AppLifecycleState.hidden:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cameraContext = CameraContext.create(
      widget.sensorConfig,
      enablePhysicalButton: widget.enablePhysicalButton,
      filter: widget.defaultFilter ?? CameraAwesome.AwesomeFilter.None,
      initialCaptureMode: widget.saveConfig?.initialCaptureMode ??
          (widget.showPreview
              ? CameraAwesome.CaptureMode.preview
              : CameraAwesome.CaptureMode.analysis_only),
      saveConfig: widget.saveConfig,
      onImageForAnalysis: widget.onImageForAnalysis,
      analysisConfig: widget.imageAnalysisConfig,
      exifPreferences: widget.saveConfig?.exifPreferences ??
          ExifPreferences(saveGPSLocation: false),
      availableFilters: widget.availableFilters,
    );

    // Initial CameraState is always PreparingState
    _cameraContext.state.when(onPreparingCamera: (mode) => mode.start());

    _captureStateListener = _cameraContext.captureState$.listen((mediaCapture) {
      if (mediaCapture != null) {
        widget.onMediaCaptureEvent?.call(mediaCapture);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CameraAwesome.AwesomeThemeProvider(
      theme: widget.theme,
      child: StreamBuilder<CameraAwesome.CameraState>(
        stream: _cameraContext.state$,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.captureMode == null ||
              snapshot.requireData is CameraAwesome.PreparingCameraState) {
            return widget.progressIndicator ??
                const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
          }
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(
                child: !widget.showPreview
                    ? widget.builder(
                        snapshot.requireData,
                        CameraAwesome.Preview.hidden(),
                      )
                    : CameraAwesome.AwesomeCameraPreview(
                        key: _cameraPreviewKey,
                        previewFit: widget.previewFit,
                        state: snapshot.requireData,
                        padding: widget.previewPadding,
                        alignment: widget.previewAlignment,
                        onPreviewTap: widget.onPreviewTapBuilder
                                ?.call(snapshot.requireData) ??
                            CameraAwesome.OnPreviewTap(
                              onTap: (
                                position,
                                flutterPreviewSize,
                                pixelPreviewSize,
                              ) {
                                snapshot.requireData.when(
                                  onPhotoMode: (photoState) =>
                                      photoState.focusOnPoint(
                                    flutterPosition: position,
                                    pixelPreviewSize: pixelPreviewSize,
                                    flutterPreviewSize: flutterPreviewSize,
                                  ),
                                  onVideoMode: (videoState) =>
                                      videoState.focusOnPoint(
                                    flutterPosition: position,
                                    pixelPreviewSize: pixelPreviewSize,
                                    flutterPreviewSize: flutterPreviewSize,
                                  ),
                                  onVideoRecordingMode: (videoRecState) =>
                                      videoRecState.focusOnPoint(
                                    flutterPosition: position,
                                    pixelPreviewSize: pixelPreviewSize,
                                    flutterPreviewSize: flutterPreviewSize,
                                  ),
                                  onPreviewMode: (previewState) =>
                                      previewState.focusOnPoint(
                                    flutterPosition: position,
                                    pixelPreviewSize: pixelPreviewSize,
                                    flutterPreviewSize: flutterPreviewSize,
                                  ),
                                );
                              },
                            ),
                        onPreviewScale: widget.onPreviewScaleBuilder
                                ?.call(snapshot.requireData) ??
                            CameraAwesome.OnPreviewScale(
                              onScale: (scale) {
                                snapshot.requireData.sensorConfig
                                    .setZoom(scale);
                              },
                            ),
                        interfaceBuilder: widget.builder,
                        previewDecoratorBuilder: widget.previewDecoratorBuilder,
                        pictureInPictureConfigBuilder:
                            widget.pictureInPictureConfigBuilder,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
