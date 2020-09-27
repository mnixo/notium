import 'package:git_bindings/git_bindings.dart';
import 'package:meta/meta.dart';

import 'package:simplewave/ssh/rsa_key_pair.dart';
import 'package:simplewave/utils/logger.dart';

Future<String> generateSSHKeys({@required String comment}) async {
  try {
    var keyPair = await RsaKeyPair.generateAsync();
    var publicKeyStr = keyPair.publicKeyString(comment: comment);
    await setSshKeys(
      publicKey: publicKeyStr,
      privateKey: keyPair.privateKeyString(),
    );
    return publicKeyStr;
  } catch (e) {
    Log.e(e);
  }

  return "";
}
