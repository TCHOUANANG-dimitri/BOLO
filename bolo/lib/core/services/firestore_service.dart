// Alias de compatibilité : redirige vers LocalDbService.
// Les repositories importent toujours FirestoreService sans changement.
export 'local_db_service.dart' show LocalDbService;

import 'local_db_service.dart';

typedef FirestoreService = LocalDbService;
