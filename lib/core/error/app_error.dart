/// Uygulama hata taksonomisi.
enum AppErrorType {
  network,
  sdk,
  userCancelled,
  timeout,
  validation,
  storage,
  unknown,
}

class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final String? userMessage;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.userMessage,
    this.originalError,
    this.stackTrace,
  });

  factory AppError.network({String? message, dynamic error}) => AppError(
        type: AppErrorType.network,
        message: message ?? 'Ağ hatası oluştu',
        userMessage: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
        originalError: error,
      );

  factory AppError.sdk({required String message, dynamic error}) => AppError(
        type: AppErrorType.sdk,
        message: message,
        userMessage: 'Bir hata oluştu. Lütfen tekrar deneyin.',
        originalError: error,
      );

  factory AppError.userCancelled() => const AppError(
        type: AppErrorType.userCancelled,
        message: 'Kullanıcı işlemi iptal etti',
      );

  factory AppError.timeout({String? message}) => AppError(
        type: AppErrorType.timeout,
        message: message ?? 'İşlem zaman aşımına uğradı',
        userMessage: 'İşlem zaman aşımına uğradı. Tekrar deneyin.',
      );

  factory AppError.validation({required String message}) => AppError(
        type: AppErrorType.validation,
        message: message,
        userMessage: message,
      );

  factory AppError.storage({required String message, dynamic error}) =>
      AppError(
        type: AppErrorType.storage,
        message: message,
        userMessage: 'Veri kaydetme/okuma hatası.',
        originalError: error,
      );

  factory AppError.unknown({dynamic error, StackTrace? stackTrace}) =>
      AppError(
        type: AppErrorType.unknown,
        message: 'Bilinmeyen hata: $error',
        userMessage: 'Beklenmeyen bir hata oluştu.',
        originalError: error,
        stackTrace: stackTrace,
      );

  @override
  String toString() => 'AppError($type): $message';
}
