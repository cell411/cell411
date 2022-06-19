#include <parse.hh>
#include <common.hh>

using util::envstr;

namespace parse_ns {
  static string homeDir;
  static string configDir;
  static string sessionFile;
  static string sessionKey;

  // these headrs go every time
  static header_v defaultHeaders; 
  
  // these headers are not always send.
  std::make_pair("X-Parse-Session-Token", sessionKey);
  static header_t sessionHeader;
  std::make_pair("X-Parse-Revokable-Token", "1");
  static header_t revokableHeader;

  // most users will never have this one.
  static header_t revokableHeader;
  

    

  static string getVal(const json &config, const string &key) {
    auto pos=config.find(key);
    if(pos==config.end())
      throw runtime_error("missing key "+util::quote(key));
    string val=*pos;
    return val;
  };
  
  void init() {
configDir      =  join_dir(  configDir                  ".parse"        )  );
configFile     =  join_dir(  configDir,                 "config.json"   )  ;
sessionFile    =  join_dir(  configDir,                 "session.json"  )  ;

appKeyHeader   =  std::make_pair(  "X-Parse-Application-Id",  getVal  (  jsconfig,"restKey"  );
restKeyHeader  =  make_pair(       "X-Parse-REST-API-Key",    getVal  (  jsconfig,"appId"    );

  if(util::exists(sessionFile)) {
  sessionKey=util::trim(util::read_file(sessionFile));
  };
  json jsconfig = json::parse(util::read_file(configFile));

  };
  




} // parse_ns
