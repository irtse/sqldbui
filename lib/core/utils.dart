import 'dart:math';

String excludeDB(String? content) {
  if (content == null) return "";
  return content.replaceAll("_", " ").replaceAll("db", "").toUpperCase();
}

String convertMath(String command) {
    if (command.contains("pi")) { command = command.replaceAll("pi", "PI()"); 
    } else if (command.contains("e")) { command = command.replaceAll("E", "2.71828182845904523536"); 
    } else if (command.contains("ln10")) { command = command.replaceAll("ln10", "2.302585092994046"); 
    } else if (command.contains("ln2")) { command = command.replaceAll("ln2", "0.6931471805599453"); 
    } else if (command.contains("log10e")) { command = command.replaceAll("log10e", "0.4342944819032518"); 
    } else if (command.contains("log2e")) { command = command.replaceAll("log2e", "1.4426950408889634"); }
    return command;
}

double Function(double) getMathFunc(String func) {
  switch (func) {
    case "acos": return acos;
    case "asin": return asin;
    case "atan": return atan;
    case "cos": return cos;
    case "exp": return exp;
    case "log": return log;
    case "sin": return sin;
    case "sqrt": return sqrt;
    case "tan": return tan;
    case "atan2": return tan;
    case "pow": return tan;
    default: return (double d) => d;
  }
}


num Function(num, num) getMathDoubleFunc(String func) {
  switch (func) {
    case "atan2": return atan2;
    case "pow": return pow;
    default: return (num d, num d2) => d;
  }
}

String getTypes(String last) { 
  switch (last) { 
    case "3gp": return   "video/3gpp";
    case "torrent": return"application/x-bittorrent";
    case "kml": return    "application/vnd.google-earth.kml+xml";
    case "gpx": return    "application/gpx+xml";
    case "csv": return    "application/vnd.ms-excel";
    case "apk": return    "application/vnd.android.package-archive";
    case "asf": return    "video/x-ms-asf";
    case "avi": return    "video/x-msvideo";
    case "bin": return    "application/octet-stream";
    case "bmp": return    "image/bmp";
    case "c": return      "text/plain";
    case "class": return  "application/octet-stream";
    case "conf": return   "text/plain";
    case "cpp": return    "text/plain";
    case "doc": return    "application/msword";
    case "docx": return   "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    case "xls": return    "application/vnd.ms-excel";
    case "xlsx": return   "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    case "exe": return    "application/octet-stream";
    case "gif": return    "image/gif";
    case "gtar": return   "application/x-gtar";
    case "gz": return     "application/x-gzip";
    case "h": return      "text/plain";
    case "htm": return    "text/html";
    case "html": return   "text/html";
    case "jar": return    "application/java-archive";
    case "java": return   "text/plain";
    case "jpeg": return   "image/jpeg";
    case "jpg": return    "image/jpeg";
    case "js": return     "application/x-javascript";
    case "log": return    "text/plain";
    case "m3u": return    "audio/x-mpegurl";
    case "m4a": return    "audio/mp4a-latm";
    case "m4b": return    "audio/mp4a-latm";
    case "m4p": return    "audio/mp4a-latm";
    case "m4u": return    "video/vnd.mpegurl";
    case "m4v": return    "video/x-m4v";
    case "mov": return    "video/quicktime";
    case "mp2": return    "audio/x-mpeg";
    case "mp3": return    "audio/x-mpeg";
    case "mp4": return    "video/mp4";
    case "mpc": return    "application/vnd.mpohun.certificate";
    case "mpe": return    "video/mpeg";
    case "mpeg": return   "video/mpeg";
    case "mpg": return    "video/mpeg";
    case "mpg4": return   "video/mp4";
    case "mpga": return   "audio/mpeg";
    case "msg": return    "application/vnd.ms-outlook";
    case "ogg": return    "audio/ogg";
    case "pdf": return    "application/pdf";
    case "png": return    "image/png";
    case "pps": return    "application/vnd.ms-powerpoint";
    case "ppt": return    "application/vnd.ms-powerpoint";
    case "pptx": return   "application/vnd.openxmlformats-officedocument.presentationml.presentation";
    case "prop": return   "text/plain";
    case "rc": return     "text/plain";
    case "rmvb": return   "audio/x-pn-realaudio";
    case "rtf": return    "application/rtf";
    case "sh": return     "text/plain";
    case "tar": return    "application/x-tar";
    case "tgz": return    "application/x-compressed";
    case "txt": return    "text/plain";
    case "wav": return    "audio/x-wav";
    case "wma": return    "audio/x-ms-wma";
    case "wmv": return    "audio/x-ms-wmv";
    case "wps": return    "application/vnd.ms-works";
    case "xml":   return "text/plain";
    case "z":      return "application/x-compress";
    case "zip":   return "application/x-zip-compressed";
    default:   return "*/*";
  }
}