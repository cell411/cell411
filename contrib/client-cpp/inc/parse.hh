#ifndef parse_hh
#define parse_hh parse_hh

#include <common.hh>
#include <json.hh>

namespace parse_ns {
  using std::pair;
  
  typedef pair<string,string> header_t;
  typedef vector<header_t> header_v;

  class config_t {
    void add_header ( const header_t & );
    void rem_headerA ( const string & key );

    const header_v &get_headers() const;
    void set_headers( const header_v & );
    void clr_headers();


    void init ( const json & );
    void init ( const string &json_file );

    const string & getConfigFile();
    void setConfigFile( const string & );

    const string & getSessionKey();
    void setSessionKey( const string & );


    const config_t &config();

  };

}

#endif
