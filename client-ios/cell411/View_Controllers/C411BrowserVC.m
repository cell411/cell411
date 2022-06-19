//
//  C411BrowserVC.m
//  cell411
//
//  Created by Milan Agarwal on 04/04/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import "C411BrowserVC.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"
@import WebKit;

@interface C411BrowserVC ()<WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIView *vuWebViewContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *vuProgress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnForward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnSafari;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnRefreshOrCancel;
@property (weak, nonatomic) IBOutlet UIToolbar *tbrNavControls;
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnForwardTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnOpenInSafariTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnRefreshOrCancelTapped:(UIBarButtonItem *)sender;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation C411BrowserVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self createWkWebView];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self loadWebPage];
    [self attachObservers];
    [self registerForNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
}

-(void)dealloc {
    [self unregisterFromNotifications];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)createWkWebView {
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc]init];
    self.webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:webViewConfiguration];
    self.webView.navigationDelegate = self;
}

-(void)configureViews {
    self.title = self.strTitle;
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    [self.vuWebViewContainer addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint *cnsLeading = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vuWebViewContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *cnsTrailing = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vuWebViewContainer attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *cnsTop = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vuWebViewContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *cnsBottom = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vuWebViewContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.vuWebViewContainer addConstraints:@[cnsLeading, cnsTop, cnsTrailing, cnsBottom]];
    
    self.barBtnBack.enabled = NO;
    self.barBtnForward.enabled = NO;
    [self applyColors];
}

-(void)applyColors {
    UIColor *backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    self.tbrNavControls.barTintColor = backgroundColor;
    self.tbrNavControls.tintColor = [C411ColorHelper sharedInstance].themeColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)loadWebPage {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:urlRequest];
}

-(void)attachObservers {
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)toggleRefreshOrCancelButtonState {
    if(self.webView.isLoading) {
        ///Set it cancel
        static UIImage *cancelImage = nil;
        if(!cancelImage) {
            cancelImage = [UIImage imageNamed:@"ic_cross"];
        }
        self.barBtnRefreshOrCancel.image = cancelImage;
    }
    else {
        ///set it refresh
        static UIImage *refreshImage = nil;
        if(!refreshImage) {
            refreshImage = [UIImage imageNamed:@"ic_refresh"];
        }
        self.barBtnRefreshOrCancel.image = refreshImage;
    }
}

//****************************************************
#pragma mark - Observer Method
//****************************************************
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"loading"]){
        self.barBtnBack.enabled = self.webView.canGoBack;
        self.barBtnForward.enabled = self.webView.canGoForward;
        [self toggleRefreshOrCancelButtonState];
    }
    else if([keyPath isEqualToString:@"estimatedProgress"]){
        self.vuProgress.hidden = self.webView.estimatedProgress == 1;
        [self.vuProgress setProgress:(float)self.webView.estimatedProgress animated:YES];
    }
}
//****************************************************
#pragma mark - WKNavigationDelegate Methods
//****************************************************
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:nil];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.vuProgress setProgress:0.0f animated:NO];
    self.barBtnSafari.enabled = [[UIApplication sharedApplication]canOpenURL:webView.URL];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *requestURL = navigationAction.request.URL;
    if(!requestURL) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if([requestURL.scheme isEqualToString:@"mailto"]) {
        ///Open mailto via open url
        [[UIApplication sharedApplication]openURL:requestURL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    ///Otherwise let other URLs to be open on this page itself
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
}
//****************************************************
#pragma mark - Action Methods
//****************************************************
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (IBAction)barBtnForwardTapped:(UIBarButtonItem *)sender {
    [self.webView goForward];
}

- (IBAction)barBtnOpenInSafariTapped:(UIBarButtonItem *)sender {
    NSURL *requestURL = self.webView.URL;
    [[UIApplication sharedApplication]openURL:requestURL];
}

- (IBAction)barBtnRefreshOrCancelTapped:(UIBarButtonItem *)sender {
    if(self.webView.isLoading) {
        [self.webView stopLoading];
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.webView.URL];
        [self.webView loadRequest:request];
    }
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
