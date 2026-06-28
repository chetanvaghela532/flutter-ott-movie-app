import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class VideoUrlPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool isWebSeries;

  const VideoUrlPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
    this.isWebSeries = false,
  });

  @override
  State<VideoUrlPlayerScreen> createState() => _VideoUrlPlayerScreenState();
}

class _VideoUrlPlayerScreenState extends State<VideoUrlPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _useWebView = false;
  bool _extractingVideoUrl = false;
  bool _webViewLoading = true;
  final GlobalKey _webViewKey = GlobalKey();
  final String _webViewId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    print("VideoUrlPlayerScreen initState: ${widget.videoUrl}");
    // Wait for first frame before initializing to avoid WebView creation issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializePlayer();
      }
    });
  }

  Future<void> _initializePlayer() async {
    print("VideoUrlPlayerScreen _initializePlayer: ${widget.videoUrl}");
    
    // For webseries, always use WebView (default embed player) only
    if (widget.isWebSeries) {
      print("WebSeries detected, using WebView (default embed player) only...");
      // Wait a bit to ensure widget is fully built before creating WebView
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _useWebView = true;
          _webViewLoading = true; // WebView will start loading
        });
      }
      return;
    }
    
    // Check if URL is a direct video file or a web page
    final isDirectVideoUrl = widget.videoUrl.toLowerCase().endsWith('.mp4') ||
        widget.videoUrl.toLowerCase().endsWith('.m3u8') ||
        widget.videoUrl.toLowerCase().endsWith('.webm') ||
        widget.videoUrl.toLowerCase().endsWith('.mov') ||
        widget.videoUrl.toLowerCase().endsWith('.avi') ||
        widget.videoUrl.toLowerCase().endsWith('.flv');
    
    // If it's not a direct video URL, go straight to WebView
    if (!isDirectVideoUrl) {
      print("URL appears to be a web page, using WebView directly...");
      // Wait a bit to ensure widget is fully built before creating WebView
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _useWebView = true;
          _webViewLoading = true; // WebView will start loading
        });
      }
      return;
    } else {
      print("URL appears to be a direct video file, trying native player...");
    }
    
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Initialize video player controller with HTTP headers for streaming URLs
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Referer': widget.videoUrl,
        },
      );

      // Add error listener to catch errors early
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.hasError) {
          print("========== VIDEO PLAYER ERROR (from listener) ==========");
          print("Error: ${_videoPlayerController!.value.errorDescription}");
          print("========================================================");
          
          // Check if it's a range request error - use WebView fallback
          String? errorDesc = _videoPlayerController!.value.errorDescription;
          if (errorDesc != null && 
              (errorDesc.contains('byte range') || 
               errorDesc.contains('Content-Length') ||
               errorDesc.contains('range request'))) {
            print("Detected range request error, switching to WebView fallback...");
            _switchToWebView(); // Fire and forget - async call
            return;
          }
          
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = errorDesc ?? 'Video playback error';
            });
          }
        }
      });

      // Wait for video to initialize with timeout
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );
      
      print("VideoUrlPlayerScreen _initializePlayer: ${_videoPlayerController!.value.aspectRatio}");
      
      // Get aspect ratio, fallback to 16/9 if invalid
      double aspectRatio = _videoPlayerController!.value.aspectRatio;
      if (aspectRatio <= 0 || aspectRatio.isInfinite || aspectRatio.isNaN) {
        aspectRatio = 16 / 9;
      }
      
      // Create Chewie controller for better UI
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: Responsive.fontSize(context, 48),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, 16),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
        // Customize player options
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        // Android specific settings
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      // Print detailed error information
      print("========== VIDEO PLAYER ERROR ==========");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: ${e.toString()}");
      
      // Handle PlatformException specifically
      if (e is PlatformException) {
        print("PlatformException Details:");
        print("  Code: ${e.code}");
        print("  Message: ${e.message}");
        print("  Details: ${e.details}");
        print("  Stacktrace: ${e.stacktrace}");
      }
      
      print("Full StackTrace:");
      print(stackTrace);
      print("========================================");
      
      if (mounted) {
        // Check if it's a range request error - use WebView fallback
        bool isRangeError = false;
        if (e is PlatformException) {
          String? message = e.message;
          if (message != null && 
              (message.contains('byte range') || 
               message.contains('Content-Length') ||
               message.contains('range request') ||
               message.contains('CoreMediaErrorDomain error -12939'))) {
            isRangeError = true;
          }
        }
        
        if (isRangeError) {
          print("Switching to WebView fallback due to range request error...");
          _switchToWebView(); // Fire and forget - async call
        } else {
          String errorMsg = 'Failed to load video';
          
          if (e is PlatformException) {
            errorMsg = 'Platform Error: ${e.code}\n${e.message ?? "Unknown error"}';
            if (e.details != null) {
              errorMsg += '\nDetails: ${e.details}';
            }
          } else {
            errorMsg = 'Error: ${e.toString()}';
          }
          
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = errorMsg;
          });
        }
      }
    }
  }

  Future<void> _switchToWebView() async {
    if (!mounted) return;
    
    // Dispose native player first
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
    
    // Wait a bit to ensure cleanup is complete before creating WebView
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    setState(() {
      _useWebView = true;
      _isLoading = false;
      _hasError = false;
      _webViewLoading = true; // WebView will start loading
    });
  }

  Future<void> _extractAndPlayDirectVideo(InAppWebViewController controller) async {
    if (_extractingVideoUrl || !mounted || _webViewController == null) return;
    
    setState(() {
      _extractingVideoUrl = true;
    });
    
    try {
      print("Attempting to extract direct video URL from page...");
      
      // Wait longer for page to fully load and JavaScript to execute
      await Future.delayed(const Duration(milliseconds: 3000));
      
      if (!mounted) return;
      
      // Try multiple times to extract video URL (in case page loads slowly)
      String? extractedUrl;
      for (int attempt = 0; attempt < 3; attempt++) {
        if (attempt > 0) {
          await Future.delayed(const Duration(milliseconds: 2000));
        }
        
        if (!mounted) return;
        
        try {
          // Extract video URL using JavaScript
          final result = await controller.evaluateJavascript(source: '''
            (function() {
              try {
                var videoUrl = null;
                
                // Method 1: Find video element with src
                var video = document.querySelector('video');
                if (video && video.src) {
                  videoUrl = video.src;
                  return videoUrl;
                }
                
                // Method 2: Find video element with source tag
                var source = document.querySelector('video source');
                if (source && source.src) {
                  videoUrl = source.src;
                  return videoUrl;
                }
                
                // Method 3: Check for common video player variables (JW Player, Video.js, etc.)
                if (typeof jwplayer !== 'undefined' && jwplayer().getPlaylist) {
                  try {
                    var playlist = jwplayer().getPlaylist();
                    if (playlist && playlist.length > 0 && playlist[0].sources && playlist[0].sources.length > 0) {
                      videoUrl = playlist[0].sources[0].file;
                      return videoUrl;
                    }
                  } catch(e) {}
                }
                
                // Method 4: Check for video.js player
                if (typeof videojs !== 'undefined') {
                  try {
                    var players = videojs.getPlayers();
                    for (var playerId in players) {
                      var player = players[playerId];
                      if (player.currentSrc) {
                        videoUrl = player.currentSrc();
                        return videoUrl;
                      }
                    }
                  } catch(e) {}
                }
                
                // Method 5: Look for iframe with video
                var iframe = document.querySelector('iframe[src*="video"], iframe[src*="player"]');
                if (iframe && iframe.src) {
                  videoUrl = iframe.src;
                  return videoUrl;
                }
                
                // Method 6: Search in script tags for video URLs (fixed regex)
                var scripts = document.getElementsByTagName('script');
                for (var i = 0; i < scripts.length; i++) {
                  try {
                    var scriptContent = scripts[i].innerHTML;
                    // Look for common video URL patterns - fixed regex escaping
                    var regex = /https?:\\/\\/[^"'\\s]+\\.(mp4|m3u8|webm|mov|avi|flv)[^"'\\s]*/gi;
                    var matches = scriptContent.match(regex);
                    if (matches && matches.length > 0) {
                      videoUrl = matches[0];
                      return videoUrl;
                    }
                  } catch(e) {}
                }
                
                return null;
              } catch(e) {
                return null;
              }
            })();
          ''');
          
          print("Extraction attempt ${attempt + 1} result: $result");
          
          if (result != null && result.toString().isNotEmpty && result != 'null') {
            String? videoUrl = result.toString().replaceAll('"', '').trim();
            
            // Validate it's a proper URL
            if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
              extractedUrl = videoUrl;
              break;
            }
          }
        } catch (e) {
          print("Error in extraction attempt ${attempt + 1}: $e");
        }
      }
      
      final result = extractedUrl;
      
      print("Final extracted video URL result: $result");
      
      if (result != null && result.isNotEmpty) {
        print("Found direct video URL: $result");
        
        // Close WebView and play in native player
        if (mounted) {
          setState(() {
            _useWebView = false;
            _extractingVideoUrl = false;
          });
          
          // Dispose WebView
          _webViewController = null;
          
          // Initialize native player with extracted URL
          await _initializePlayerWithUrl(result);
          return;
        }
      }
      
      print("Could not extract direct video URL, continuing with WebView");
      
      if (mounted) {
        setState(() {
          _extractingVideoUrl = false;
        });
      }
    } catch (e) {
      print("Error extracting video URL: $e");
      if (mounted) {
        setState(() {
          _extractingVideoUrl = false;
        });
      }
    }
  }

  Future<void> _initializePlayerWithUrl(String videoUrl) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      print("Initializing native player with extracted URL: $videoUrl");
      
      // Initialize video player controller
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Referer': widget.videoUrl,
        },
      );
      
      // Wait for video to initialize
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );
      
      // Get aspect ratio
      double aspectRatio = _videoPlayerController!.value.aspectRatio;
      if (aspectRatio <= 0 || aspectRatio.isInfinite || aspectRatio.isNaN) {
        aspectRatio = 16 / 9;
      }
      
      // Create Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: aspectRatio,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error initializing player with extracted URL: $e");
      // Fallback to WebView if native player fails
      if (mounted) {
        setState(() {
          _isLoading = false;
          _useWebView = true;
        });
      }
    }
  }

  Future<void> _openInNativePlayer() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(uri)) {
        // On iOS, this will open in the native AVPlayer
        // On Android, it will open in the default video player
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        // Close the dialog after opening in native player
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open video URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error opening in native player: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: widget.title != null
            ? Text(
                widget.title!,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
      body: SafeArea(
        // top: false,
        // bottom: false,
        child: _isLoading
            ? Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            : _hasError
                ? Container(
                    color: Colors.black,
                    padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: Responsive.fontSize(context, 48),
                          ),
                          SizedBox(height: Responsive.spacing(context, 16)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.spacing(context, 16),
                            ),
                            child: Text(
                              _errorMessage ?? 'Video unavailable',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.fontSize(context, 14),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 24)),
                          ElevatedButton.icon(
                            onPressed: _openInNativePlayer,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Open in Native Player'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.spacing(context, 24),
                                vertical: Responsive.spacing(context, 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _useWebView
                    ? Stack(
                        children: [
                          Container(
                            color: Colors.black,
                            key: _webViewKey,
                            child: InAppWebView(
                          key: ValueKey('webview_${_webViewId}_${widget.videoUrl.hashCode}'),
                          initialUrlRequest: URLRequest(
                            url: WebUri(widget.videoUrl),
                            headers: {
                              'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
                              'Referer': widget.videoUrl,
                              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                              'Accept-Language': 'en-US,en;q=0.9',
                            },
                          ),
                          initialSettings: InAppWebViewSettings(
                            mediaPlaybackRequiresUserGesture: false,
                            allowsInlineMediaPlayback: true,
                            javaScriptEnabled: true,
                            domStorageEnabled: true,
                            useHybridComposition: true,
                            transparentBackground: false,
                            supportZoom: false,
                            builtInZoomControls: false,
                            displayZoomControls: false,
                            allowsBackForwardNavigationGestures: false,
                            javaScriptCanOpenWindowsAutomatically: true,
                            useShouldOverrideUrlLoading: true,
                          ),
                          onWebViewCreated: (controller) {
                            _webViewController = controller;
                            print("WebView created for video playback");
                          },
                          onLoadStart: (controller, url) {
                            print("WebView loading: $url");
                            if (mounted) {
                              setState(() {
                                _webViewLoading = true;
                              });
                            }
                            // Inject CSS early to prevent white screen
                            controller.evaluateJavascript(source: '''
                              (function() {
                                if (document.head) {
                                  var style = document.createElement('style');
                                  style.innerHTML = 'body { background-color: #000000 !important; } html { background-color: #000000 !important; }';
                                  document.head.appendChild(style);
                                }
                              })();
                            ''');
                          },
                          onPageCommitVisible: (controller, url) async {
                            // Inject CSS when page becomes visible
                            try {
                              await controller.evaluateJavascript(source: '''
                                (function() {
                                  var style = document.createElement('style');
                                  style.innerHTML = 'body { background-color: #000000 !important; } html { background-color: #000000 !important; }';
                                  if (document.head) {
                                    document.head.appendChild(style);
                                  } else {
                                    document.addEventListener('DOMContentLoaded', function() {
                                      document.head.appendChild(style);
                                    });
                                  }
                                })();
                              ''');
                            } catch (e) {
                              print("Error injecting CSS on page commit: $e");
                            }
                          },
                          onProgressChanged: (controller, progress) {
                            // Hide loading indicator when progress reaches 100%
                            if (progress == 100 && mounted) {
                              // Add a small delay to ensure content is visible
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (mounted) {
                                  setState(() {
                                    _webViewLoading = false;
                                  });
                                }
                              });
                            }
                          },
                          onLoadStop: (controller, url) async {
                            print("WebView loaded: $url");
                            
                            // Inject CSS to set background to black and hide white screen
                            try {
                              await controller.evaluateJavascript(source: '''
                                (function() {
                                  var style = document.createElement('style');
                                  style.innerHTML = 'body { background-color: #000000 !important; } html { background-color: #000000 !important; }';
                                  document.head.appendChild(style);
                                })();
                              ''');
                            } catch (e) {
                              print("Error injecting CSS: $e");
                            }
                            
                            // Hide loading indicator after WebView loads (with delay)
                            Future.delayed(const Duration(milliseconds: 800), () {
                              if (mounted) {
                                setState(() {
                                  _webViewLoading = false;
                                });
                              }
                            });
                            
                            // For webseries, skip video extraction and use only default embed player
                            if (widget.isWebSeries) {
                              print("WebSeries: Using default embed player only, skipping video extraction");
                              return;
                            }
                            
                            // Try to extract direct video URL and play in native player
                            if (!_extractingVideoUrl) {
                              _extractAndPlayDirectVideo(controller);
                            }
                            
                            // Also try to find and play video elements on the page
                            try {
                              await controller.evaluateJavascript(source: '''
                                (function() {
                                  // Find video elements
                                  var videos = document.querySelectorAll('video');
                                  if (videos.length > 0) {
                                    videos.forEach(function(video) {
                                      video.setAttribute('playsinline', '');
                                      video.setAttribute('webkit-playsinline', '');
                                      video.setAttribute('controls', '');
                                      video.style.width = '100%';
                                      video.style.height = '100%';
                                      video.style.objectFit = 'contain';
                                      try {
                                        video.play();
                                      } catch(e) {
                                        console.log('Auto-play prevented:', e);
                                      }
                                    });
                                    return 'Found ' + videos.length + ' video element(s)';
                                  }
                                  
                                  // Try to find iframe with video
                                  var iframes = document.querySelectorAll('iframe');
                                  if (iframes.length > 0) {
                                    return 'Found ' + iframes.length + ' iframe(s)';
                                  }
                                  
                                  return 'No video elements found';
                                })();
                              ''');
                            } catch (e) {
                              print("Error executing JavaScript: $e");
                            }
                          },
                          onReceivedError: (controller, request, error) {
                            print("WebView error: ${error.description}");
                            if (mounted) {
                              setState(() {
                                _hasError = true;
                                _errorMessage = 'WebView error: ${error.description}';
                              });
                            }
                          },
                          onConsoleMessage: (controller, consoleMessage) {
                            print("WebView console: ${consoleMessage.message}");
                          },
                          shouldOverrideUrlLoading: (controller, navigationAction) async {
                            // Allow all navigation
                            return NavigationActionPolicy.ALLOW;
                          },
                        ),
                          ),
                          // Loading indicator overlay while WebView is loading
                          if (_webViewLoading)
                            Container(
                              color: Colors.black,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      )
                    : SizedBox.expand(
                        child: Chewie(
                          controller: _chewieController!,
                        ),
                      ),
      ),
    );
  }
}

