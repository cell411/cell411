#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <util.hh>
#include <sstream>
#include <boost/lexical_cast.hpp>
#include <dbg.hh>
#include <fstream>

vector<string> util::ws_split( const string &str )
{
  vector<string> res;
  auto b(str.begin()), e(str.end());
  while(b!=e) {
    while(b!=e && isspace(*b))
      b++;
    if(b!=e) {
      auto sb=b;
      while(b!=e && !isspace(*b))
        b++;
      auto se=b;
      res.push_back(string(sb,se));
    };
  };
  return res;
}
vector<string> util::split( char sep, const string &str )
{
  vector<string> res;
  auto b(str.begin());
  auto e(str.end());
  if(b==e)
    return res;
  while(true)
  {
    auto s(find(b,e,sep));
    res.push_back(string(b,s));
    if(s==e)
      break;
    b=s+1;
  };
  return res;
}
string util::quote(const string &str) {
  if(str.find('"') == string::npos) {
    return "\""+str+"\"";
  } else {
    string res;
    res.push_back('"');
    for(auto b(str.begin()), e(str.end()); b!=e; b++){
      if(*b == '"')
        res.push_back('\\');
      res.push_back(*b);
    };
    res.push_back('"');
    return res;
  };
};
string util::trim(const string &str)
{
	auto b(str.begin());
	auto e(str.end());
	if(b==e)
		return str;
	while(b!=e && isspace(*--e))
		;
	while(b!=e && isspace(*b))
		++b;
	return string(b,++e);
};
string util::read_file(const string &name)
{
	ifstream file(name);
  if(!file)
    xthrowre("failed to read file " << name << ":" << strerror(errno));
	std::stringstream buf;
	buf << file.rdbuf();
	string res=buf.str();
	cout << "read " << res.length() << " bytes" << endl;
	return res;
};
ssize_t util::write_file(const string &name, const string &text)
{
  xtrace("writing: " << name);
  ofstream ofile;
  ofile.open(name,ios::app);
  if(!ofile)
    xthrowre("open:"<<name<<": "<<strerror(errno));
  ofile<<text;
  if(!ofile)
    xthrowre("error writing "<<name);
  return text.length();
};
static size_t try_read(int &fd, char* buf, size_t size)
{
  if(fd < 0)
    return 0;
  int res=read(fd,buf,size);
  if(res<0) {
    fd=-1;
    return 0;
  };
  return res;
};
int util::xfcntl(int fd, int cmd, int arg)
{
  int res=fcntl(fd,cmd,arg);
  if(res<0)
    xthrowre("fcntl:" << strerror(errno));
  return res;
};
void util::xexecv(const char *exe, char * const *args)
{
  execv(exe,args);
  xthrowre("execv:" << exe << ":" << strerror(errno));
};
int util::xfork()
{
  int res=fork();
  if(res<0)
    xthrowre("fork:"<<strerror(errno));
  return res;
};
void ls_fds() {
  ostringstream b_cmd;
  b_cmd << "ls -l /proc/" << getpid() << "/fd/";
  string cmd=b_cmd.str();
  cout << "running: (" << cmd << ")" << endl;
  system(cmd.c_str());
};
string util::read_gpg_file(const string &name)
{
  static int first_time=unlink("log/gpg.err");
  int out_pipe[2];
  xpipe(out_pipe);
  int pid=-1;
  if(!(pid=fork()))
  {
    int efd = xopen("log/gpg.err",O_WRONLY|O_CREAT|O_APPEND);
    dup2(efd,2);
    xclose(efd);
    xclose(out_pipe[0]);
    if(out_pipe[1]!=1) {
      xdup2(out_pipe[1],1);
      xclose(out_pipe[1]);
    };
    const char *args[]={
      "gpg",
      "-d",
      name.c_str(),
      0
    };
    xexecv("/usr/bin/gpg",(char*const*)args);
    xthrowre("execve:/usr/bin/gpg:"<<strerror(errno));
  } else {
    char buf[8192];
    int &ofd=out_pipe[0];
    xclose(out_pipe[1]);
    string text;
    while(true)
    {
      int res=read(ofd,buf,sizeof(buf));
      if(res<0)
        xthrowre("read:"<<ofd<<":"<<strerror(errno));
      if(res==0)
        break;
      text.append(buf,res);
    };
    xclose(ofd);
    int wstatus=0;
    //int waitid(idtype_t idtype, id_t id, siginfo_t *infop, int options);
    siginfo_t info;
    waitid(P_PID,pid,&info,WEXITED);
//       xexpose(info.si_pid);
//       xexpose(info.si_uid);
//       xexpose(info.si_uid);
//       xexpose(info.si_signo);
//       xexpose(info.si_status);
//       xexpose(info.si_code);
    return text;
  };
};
bool util::exists(const char *name)
{
	struct stat buf;
	if(stat(name,&buf)<0){
		return false;
	};
	return true;
};

util::fd_streambuf::~fd_streambuf()
{
  if(cout.rdbuf()==this)
    cout.rdbuf(0);
  if(cerr.rdbuf()==this)
    cerr.rdbuf(0);
};

using namespace boost;
using namespace std;
using namespace util;
int util::open_log(const string &in_fn, bool save)
{
  string fn(in_fn);
  if( save ) {
    struct stat stat_buf;
    for(int i=100;i<1000;i++)
    {
      int res=stat(fn.c_str(),&stat_buf);
      if( res && errno==ENOENT ) {
        if(in_fn != fn )
          xrename(in_fn.c_str(),fn.c_str());
        return xopen(in_fn.c_str(),O_WRONLY|O_CREAT|O_APPEND,0644);
      };
      fn=in_fn+"."+lexical_cast<string>(i);
    };
    xthrowre("clean your log dir, you have 1000 of them!");
  } else {
    return xopen(in_fn.c_str(),O_WRONLY|O_CREAT|O_APPEND,0644);
  };
};
int util::xrename(const char *ofn, const char *nfn)
{
  int res=rename(ofn,nfn);
  if(res<0)
    xcroak("rename("<<ofn<<","<<nfn<<"):" << strerror(errno));
  return res;
};
int util::xpipe(int fds[2])
{
  int res=pipe(fds);
  if(res<0)
    xthrowre("xpipe:" << &fds << ":" << strerror(errno));
  return res;
};
int util::xdup2(int fd, int ofd)
{
  int res=dup2(fd,ofd);
  if(res<0)
    xthrowre("xdup2:" << fd << "," << ofd << ":" << strerror(errno));
  return res;
};
int util::xdup(int fd)
{
  int res=dup(fd);
  if(res<0)
    xthrowre("xdup2:" << fd << ":" << strerror(errno));
  return res;
};
int util::xopen(const char *fn, int flags, int mode)
{
  int res=open(fn,flags,mode);
  if(res<0)
    xthrowre("open:" << (fn?fn:"<null>") << ":" << strerror(errno));
  return res;
};
int util::xclose(int fd)
{
  auto res=close(fd);
  if(res<0)
    xthrowre("xclose:" << fd << ":" << strerror(errno));
  return res;
};
void util::split_stream(const string &logname) {
  int fd=xopen(logname.c_str(), O_TRUNC|O_WRONLY|O_CREAT,0777);
  static util::fd_streambuf obuf(1,fd);
  static util::fd_streambuf ebuf(2,fd);
  cout.rdbuf(&obuf);
  cerr.rdbuf(&ebuf);
  cout << logname << ":1:started\n";
};
ostream &operator<<(ostream &lhs, const type_info &rhs)
{
  return lhs << demangle(rhs.name());
};
ostream &operator<<(ostream &lhs, const std::exception &rhs)
{
  return lhs << typeid(rhs) << "( "  <<rhs.what() << " )";
};
