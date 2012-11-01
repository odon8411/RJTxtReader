#import <UIKit/UIKit.h>
#import "KDBook.h"
#import "PageView.h"
#import "RJBookData.h"
#import "RJBookIndexViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface KDBooKViewController : UIViewController <KDBookDelegate,BookReadDelegate>{
	
	PageView  *bookLabel;	
    
	KDBook   *mBook;
	NSUInteger bookIndex;
	UISlider *bookSlider;
	UIView   *headView;
	
	NSUInteger  pageIndex;
    BOOL isNavHideflage;
    
    CGPoint gestureStartPoint;
    CGFloat currentLight;
    
    BOOL isShowIndex;
    UIView *pageNumberView ;
    UILabel *pageNumberLabel;
}

@property (nonatomic, readwrite)NSUInteger bookIndex;

-(void)back:(id)sender;
-(void) ShowHideNav;
-(void) HideNav;
-(void) doBookmark;
-(void) savePlace:(NSUInteger) nPage;
-(void) showPage;
- (void)updatePageNumberText:(NSInteger)page;

//toolbar的响应事件
-(void) doPre;
-(void) doFont;
-(void) doColor;
-(void) doNext;
-(void) doIndex;


@end
