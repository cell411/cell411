#include <common.hh>
#include <iostream>
#include <stdexcept>
#include <exception>
#include <util.hh>
#include <json.hh>
#define CPPHTTPLIB_OPENSSL_SUPPORT
#include <httplib.hh>
#define CA_CERT_FILE "./ca-bundle.crt"


using std::cout;
using std::cerr;
using std::endl;
using std::exception;
using std::runtime_error;
using std::list;




httplib::SSLClient cli("ftp.gnu.org", 21);
httplib::Headers defaultHeaders;
string sessionFile;
string getContentType(const httplib::Result &res) {
  string type = res->get_header_value("Content-Type");
  cout << "type: " << type << endl;
  if(type.find(';')!=string::npos) {
    vector<string> parts = util::split(';',type);
    type=parts[0];
  };
  return type;
};
httplib::Params params;

cli.set_ca_cert_path(CA_CERT_FILE);
cli.enable_server_certificate_verification(true);


if (auto res = cli.Get("/parse/login",params,)) {
    cout << typeid(res)<< endl << endl;
    cout << res->status << endl;
    if(res->status != 200)
      throw runtime_error("http GET failed");
    string type = getContentType(res);
    if(type!="application/json")
      throw runtime_error("content-type != application/json");

    json js = json::parse(res->body);
    auto keyItr = js.find("sessionToken");
    if(keyItr != js.end()){
      string sessionToken = *keyItr;
      util::write_file(sessionFile,sessionToken+"\n\n");
    };
  } else {
    cout << "error code: " << res.error() << std::endl;
    auto result = cli.get_openssl_verify_result();
    if (result) {
      cout << "verify error: " << X509_verify_cert_error_string(result) << endl;
    }
  }

  return 0;
}
void checkLogin() {
  string content="{}";
  if (auto res = cli.Post("/parse/functions/checkLogin",defaultHeaders,
        content,"application/json"))
  {
    cout << typeid(res)<< endl << endl;
    string body = res->body;
    cout << "body: " << body << endl;
  } else {
    cout << "failed to call checkLogin" << endl;
  };
};
string getVal(const json &config, const string &key) {
  auto pos=config.find(key);
  if(pos==config.end())
    throw runtime_error("missing key "+util::quote(key));
  string val=*pos;
  return val;
};
int main(int argc, char** argv) {
  try {
    if(!getenv("HOME"))
      throw runtime_error("HOME not set");
    string HOME = getenv("HOME");
    string configFile = HOME+"/.parse/config.json";;
    json config = json::parse(util::read_file(configFile));
    string appId = getVal(config,"appId");
    defaultHeaders.insert(std::make_pair("X-Parse-Application-Id",appId));
    string restKey = getVal(config,"restKey");
    defaultHeaders.insert(std::make_pair("X-Parse-REST-API-Key",restKey));


    checkLogin();
  } catch ( exception &e ) {
    cout << e.what() << endl;
  };
  return 0;
};
