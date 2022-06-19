
#ifndef util_hh
#define util_hh util_hh

#include <common.hh>

namespace util {
  using std::streambuf;
  class fd_streambuf : public streambuf
  {
    int fd1;
    int fd2;
    public:
    fd_streambuf(int fd1, int fd2)
      : fd1(fd1)
        , fd2(fd2)
    {
    };
    int overflow(int c = EOF )
    {
      char tmp[1];
      tmp[0]=(c&0xff);
      write(fd1,tmp,1);
      write(fd2,tmp,1);
      return traits_type::to_int_type( c );
    };
    virtual ~fd_streambuf();
  };

  template<typename itr_t>
    inline string join(char c, itr_t b, itr_t e)
    {
      string res;
      if(b==e)
        return res;
      res=*b++;
      if(b==e)
        return res;
      while(b!=e) {
        res+=c;
        res+=*b++;
      };
      return res;
    };
  template<typename cont_t>
    inline string join(char c, cont_t cont)
    {
      return join(c,cont.begin(),cont.end());
    };
  vector<string> ws_split( const string &str );
  vector<string> split( char sep, const string &str );
  void split_stream(const string &logname);
  template<typename itr_t, typename val_t>
    bool contains(itr_t b, itr_t e, const val_t &val){
      while(b!=e) {
        if( *b++ == val )
          return true;
      }
      return false;
    };
  template<typename con_t, typename val_t>
    bool contains(const con_t &con, const val_t &val) {
      return contains(begin(con),end(con),val);
    };
  string trim(const string &str);
  bool exists(const char *path);
  inline bool exists(const string &fn){
    return exists(fn.c_str());
  };
  string read_file(const string &path);
  string read_gpg_file(const string &name);
  ssize_t write_file(const string &name, const string &text);
  string quote(const string &str);
  int open_log(const string &in_fn, bool save=false);
  int xrename(const char *ofn, const char *nfn);
  int xdup2(int fd, int ofd);
  int xdup(int fd);
  int xpipe(int pipe[2]);
  int xfork();
  //FIXME
  void xexecv(const char *file, char * const *args);
  int xfcntl(int fd, int cmd, int arg);
  int xopen(const char *fn, int flags, int mode=0644);
  int xclose(int fd);

  inline string envstr(const string &var) {
    const char *tmp=getenv(var.c_str());
    return tmp?tmp:"";
  };
};

#endif

