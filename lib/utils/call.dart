import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class Call extends StatefulWidget {
  const Call({super.key});

  static const String appId = "b7a63817a430453db9eb95d92154e7a9";
  @override
  State<Call> createState() => _CallState();
}

class _CallState extends State<Call> {
  // A 32-byte string for encryption.
  String encryptionKey =
      "539d53716fb6f8be2c3b2cd7bd69f8ab839dea5241a2b07cb4d32fc3bbecbae4";

// A 32-byte string in Base64 format for encryption.
  String encryptionSaltBase64 = "ODwrcCS4XQI3xM131W+k2c0gGvd6dhbykcNFRe/jYyY=";

  bool isBroadcaster = true;
  // 1 for Broadcaster, 2 for Audience
  String channelName = "test";
  // channel name
  int UID = 0;
  // uid of the local user
  int? _remoteUid;
  // uid of the remote user
  bool _isJoined = false;
  // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine;
  // Agora App ID
  Widget _status() {
    String statusText;

    if (!_isJoined) {
      statusText = 'Join a channel';
    } else if (_remoteUid == null)
      statusText = 'Waiting for a remote user to join...';
    else
      statusText = 'Connected to remote user, uid:$_remoteUid';

    return Text(
      statusText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void enableEncryption() {
    if (encryptionSaltBase64.isEmpty || encryptionKey.isEmpty) {
      print("Please set encryption key and salt");
      return;
    }

    // Convert the salt string into the required format
    Uint8List bytes = base64Decode(encryptionSaltBase64);

    // An object to specify encryption configuration.
    EncryptionConfig config = EncryptionConfig(
        encryptionMode: EncryptionMode.aes128Gcm2,
        encryptionKey: encryptionKey,
        encryptionKdfSalt: bytes);

    // Enable media encryption using the configuration
    agoraEngine.enableEncryption(enabled: true, config: config);

    print("Media encryption enabled");
  }

  Future<void> joinChannelWithToken(
      String channelName, int localUid, bool isBroadcaster2) async {
    String token = '';

    token = await fetchToken(localUid, channelName, isBroadcaster2);

    void renewToken() async {
      String token;

      try {
        // Retrieve a token from the server
        token = await fetchToken(localUid, channelName, isBroadcaster2);
      } catch (e) {
        // Handle the exception
        print('Error fetching token');
        return;
      }

      // Renew the token
      agoraEngine.renewToken(token);
      print("Token renewed");
    }

    @override
    RtcEngineEventHandler getEventHandler() {
      return RtcEngineEventHandler(
          // Listen for the event that the token is about to expire
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        print('Token expiring...');
        renewToken();
        // Notify the UI through the eventCallback
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["token"] = token;
        print("onTokenPrivilegeWillExpire" + eventArgs.toString());
      }
          // Other event handlers
          );
    }

    return join(
        channelName: channelName,
        token: token,
        clientRole: (isBroadcaster2)
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
        localUid: localUid);
  }

  Future<String> fetchToken(
      int uid, String channelName, bool isBroadcaster2) async {
    // Set the token role,
    // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
    int tokenRole = isBroadcaster2 ? 1 : 2;

    // Prepare the Url
    String url =
        'https://agora-token-server-l8f3.onrender.com/rtc/$channelName/'
        '${tokenRole.toString()}/uid/${uid.toString()}'
        '?expiry=${"3600"}';

    // Send the http GET request
    final response = await http.get(Uri.parse(url));

    // Read the response
    if (response.statusCode == 200) {
      // The server returned an OK response
      // Parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      // Store the channelName and uid
      // Return the token
      return newToken;
    } else {
      // Throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: Call.appId));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void join(
      {required String channelName,
      required String token,
      required ClientRoleType clientRole,
      required int localUid}) async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    enableEncryption();
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: localUid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }
}
