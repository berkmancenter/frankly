(function () {
  var testTool = window.testTool;
  // get meeting args from url
  var tmpArgs = testTool.parseQuery();
  // Args
  // mn: meetingNumber
  // name: b64DecodeUnicode(name) or name
  // pwd: password
  // role: role
  // email: userEmail
  // lsignature: signature

  var meetingConfig = {
    apiKey: tmpArgs.apiKey,
    meetingNumber: tmpArgs.mn,
    userName: (function () {
      if (tmpArgs.name) {
        try {
          return testTool.b64DecodeUnicode(tmpArgs.name);
        } catch (e) {
          return tmpArgs.name;
        }
      }
      return 'Anonymous';
    })(),
    passWord: tmpArgs.pwd,
    leaveUrl: "/index.html",
    role: parseInt(tmpArgs.role, 10),
    userEmail: (function () {
      try {
        return testTool.b64DecodeUnicode(tmpArgs.email);
      } catch (e) {
        return tmpArgs.email;
      }
    })(),
    signature: tmpArgs.signature || "",
  };

  console.log(JSON.stringify(ZoomMtg.checkSystemRequirements()));

  /*
   'apiKey': 'u66RU7-zSbSw3F0O_KXpNw',
        'email': 'dantheman252@gmail.com',
        'mn': '95506066857',
        'name': 'John Wayne',
        'pwd': 'Tng1SDlZMFA1Q25RVnNqL1FlWFQ0UT09',
        'role': '1',
        // email: userEmail
        'signature':
            'dTY2UlU3LXpTYlN3M0YwT19LWHBOdy51bmRlZmluZWQuMTYwNTMxNDU4Mzc2Ny51bmRlZmluZWQuak1sWnFCQUVhRnQ3aDJFSGhlWUZpMmxQeEp1UDZGbjRoR1dsTkE4VGlUST0=',
      
            u66RU7-zSbSw3F0O_KXpNw

  /*
  ZoomMtg.init({
    
    });
    */

  ZoomMtg.preLoadWasm();
  ZoomMtg.prepareJssdk();
  function beginJoin(signature) {
    ZoomMtg.init({
      leaveUrl: meetingConfig.leaveUrl,
      webEndpoint: meetingConfig.webEndpoint,
      showMeetingHeader: false, 
      disableInvite: true, 
      disableCallOut: true, 
      disableRecord: true, 
      disableJoinAudio: false,
      isSupportAV: true, 
      isSupportChat: false, 
      isSupportQA: false, 
      isSupportCC: false, 
      meetingInfo: [
        'participant',
        'dc'
      ],
      success: function () {
        console.log(meetingConfig);
        console.log("signature", signature);
        ZoomMtg.join({
          meetingNumber: meetingConfig.meetingNumber,
          userName: meetingConfig.userName,
          signature: signature,
          apiKey: meetingConfig.apiKey,
          userEmail: meetingConfig.userEmail,
          passWord: meetingConfig.passWord,
          success: function (res) {
            console.log("join meeting success");
          },
          error: function (res) {
            console.log(res);
          },
        });
      },
      error: function (res) {
        console.log(res);
      },
    });

    ZoomMtg.inMeetingServiceListener('onUserJoin', function (data) {
      console.log('inMeetingServiceListener onUserJoin', data);
    });
  
    ZoomMtg.inMeetingServiceListener('onUserLeave', function (data) {
      console.log('inMeetingServiceListener onUserLeave', data);
    });
  
    ZoomMtg.inMeetingServiceListener('onUserIsInWaitingRoom', function (data) {
      console.log('inMeetingServiceListener onUserIsInWaitingRoom', data);
    });
  
    ZoomMtg.inMeetingServiceListener('onMeetingStatus', function (data) {
      console.log('inMeetingServiceListener onMeetingStatus', data);
    });
  }

  beginJoin(meetingConfig.signature);
})();
