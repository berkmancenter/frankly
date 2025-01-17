class Environment {
  // Firebase connection properties
  static const firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'any');
  static const firebaseAppId =
      String.fromEnvironment('FIREBASE_APP_ID', defaultValue: 'any');
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'any',
  );
  static const firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'dev');
  static const firebaseAuthDomain =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'any');
  static const firebaseDatabaseUrl = String.fromEnvironment(
    'FIREBASE_DATABASE_URL',
    defaultValue: 'http://dev.firebaseio.com',
  );
  static const firebaseStorageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'any');
  static const firebaseMeasurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: 'any');
  static const functionsUrlPrefix = String.fromEnvironment(
    'FUNCTIONS_URL_PREFIX',
    defaultValue: 'http://127.0.0.1:5001/dev/us-central1',
  );

  static const sentryDSN = String.fromEnvironment('SENTRY_DSN');
  static const sentryEnvironment = String.fromEnvironment('SENTRY_ENVIRONMENT');

  // App branding and URL properties
  static const appName = String.fromEnvironment('APP_NAME');
  static const sidebarFooter = String.fromEnvironment('SIDEBAR_FOOTER');
  static const copyrightStatement =
      String.fromEnvironment('COPYRIGHT_STATEMENT');
  static const shareLinkUrl = String.fromEnvironment('SHARE_LINK_URL');
  static const termsUrl = String.fromEnvironment('TERMS_URL');
  static const pricingUrl = String.fromEnvironment('PRICING_URL');
  static const aboutUrl = String.fromEnvironment('ABOUT_URL');
  static const privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
  static const helpCenterUrl = String.fromEnvironment('HELP_CENTER_URL');
  static const createEventHelpUrl =
      String.fromEnvironment('CREATE_EVENT_HELP_URL');
  static const createTemplateHelpUrl =
      String.fromEnvironment('CREATE_TEMPLATE_HELP_URL');
  static const troubleshootingGuideUrl =
      String.fromEnvironment('TROUBLESHOOTING_GUIDE_URL');
  static const subscriptionServicesAgreementUrl =
      String.fromEnvironment('SUBSCRIPTION_SERVICES_AGREEMENT_URL');
  static const logoUrl = String.fromEnvironment('LOGO_URL');

  // SAAS connection properties
  static const cloudinaryDefaultPreset =
      String.fromEnvironment('CLOUDINARY_DEFAULT_PRESET');
  static const cloudinaryImagePreset =
      String.fromEnvironment('CLOUDINARY_IMAGE_PRESET');
  static const cloudinaryVideoPreset =
      String.fromEnvironment('CLOUDINARY_VIDEO_PRESET');
  static const cloudinaryCloudName =
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const linkPreviewApiKey =
      String.fromEnvironment('LINK_PREVIEW_API_KEY');

  // Development settings/features
  static const enableFakeParticipants =
      bool.fromEnvironment('ENABLE_FAKE_PARTICIPANTS');
  static const enableDevEventSettings =
      bool.fromEnvironment('ENABLE_DEV_EVENT_SETTINGS');
  static const enableDevAdminSettings =
      bool.fromEnvironment('ENABLE_DEV_ADMIN_SETTINGS');
  static const enableTraceLog = bool.fromEnvironment('ENABLE_TRACE_LOG');
  static const enableEmulators = String.fromEnvironment(
    'EMULATORS',
    defaultValue: 'functions,firestore,auth,database',
  );
}
