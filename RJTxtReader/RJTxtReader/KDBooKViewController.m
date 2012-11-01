

#import "KDBooKViewController.h"


@implementation KDBooKViewController
@synthesize bookIndex;

- (void)exchangeAnimate:(NSInteger)add{
    
    CATransition *animation = [CATransition animation];
	animation.duration = 0.4f;
	animation.delegate = self;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.type = kCATransitionPush;
	//animation.subtype = kCATransitionFromLeft;
    switch (2+add) {
        case 0:
            animation.subtype = kCATransitionFromTop;
            break;
        case 1:
            animation.subtype = kCATransitionFromBottom;
            break;
        case 2:
            animation.subtype = kCATransitionFromRight;
            break;
        case 3:
            animation.subtype = kCATransitionFromLeft;
            break;
        default:
            break;
    }
    [[bookLabel layer] addAnimation:animation forKey:nil];
    return;
    
	[UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:1.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
	switch (2+add) {
		case 0:
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:bookLabel cache:YES];//oglFlip, fromLeft 
			break;
		case 1:
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:bookLabel cache:YES];//oglFlip, fromRight 	 
			break;
		case 2:
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:bookLabel cache:YES];
			break;
		case 3:
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:bookLabel cache:YES];
			break;
		default:
			break;
	}
    
	[UIView commitAnimations];
}

-(void) savePlace:(NSUInteger) nPage
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    RJSingleBook* singleBook = [[RJBookData sharedRJBookData].books objectAtIndex:bookIndex];
    [saveDefaults setInteger:nPage forKey:singleBook.name];
    [saveDefaults synchronize];
}

- (void)sliderEvent{
	NSUInteger page = bookSlider.value;
	pageIndex = page;
	bookLabel.text = [mBook stringWithPage:pageIndex];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];
    
    CGFloat deltaX = fabsf(gestureStartPoint.x - currentPosition.x);
    CGFloat deltaY = fabsf(gestureStartPoint.y - currentPosition.y);
    if (deltaX < 10 && deltaY < 10) { //单击
        [self ShowHideNav];
        if (isNavHideflage == NO)
        {
            [self performSelector:@selector(HideNav) withObject:self afterDelay:10.0];
        }
        return;
    }
    if(deltaX > deltaY)
    {
        if(gestureStartPoint.x < currentPosition.x) //从左往右，往前翻页
        {
            [self doPre];
        }
        else
        {
            [self doNext];
        }
    }
}


-(void) HideNav
{
    if(isNavHideflage == NO && isShowIndex == NO)
    {
        [self ShowHideNav];
    }
}

-(void) ShowHideNav
{
    isNavHideflage=!isNavHideflage;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [self.navigationController setNavigationBarHidden:isNavHideflage animated:TRUE];
    [self.navigationController setToolbarHidden:isNavHideflage animated:TRUE];
    pageNumberView.hidden = isNavHideflage;
    [UIView commitAnimations];
    
}

- (id)init{
	self = [super init];
	if (self) {
		// add code here		
	}
	return self;
}


-(void)back:(id)sender{
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UIView* aView = [navBar.subviews objectAtIndex:0];
    aView.hidden = YES;
    
    //停止线程
    [mBook setStopInit:YES];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    [self.navigationController setToolbarHidden:YES animated:TRUE];

    [self.navigationController popViewControllerAnimated:YES];
}

//添加书签
-(void) doBookmark
{
    RJSingleBook* singleBook = [[RJBookData sharedRJBookData].books objectAtIndex:bookIndex];
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    //读取旧的书签
    NSMutableArray *ChatperArray = nil;
    NSMutableArray *PageNumArray = nil;
    NSMutableArray *BookTimeArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_chatper.plist"]]])
    {
        ChatperArray = [NSMutableArray arrayWithContentsOfFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_chatper.plist"]]];
        PageNumArray = [NSMutableArray arrayWithContentsOfFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_pagenum.plist"]]];
        BookTimeArray = [NSMutableArray arrayWithContentsOfFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_booktime.plist"]]];
    }
    else{
        ChatperArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        PageNumArray = [[[NSMutableArray alloc] initWithCapacity:1]  autorelease];
        BookTimeArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    }
    //判断是否已添加此标签
    for(NSUInteger i=0;i<[PageNumArray count];i++)
    {
        if([[PageNumArray objectAtIndex:i] integerValue] == pageIndex)
        {
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经添加此书签" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            return;
        }
    }
    //添加新的书签
    [PageNumArray addObject:[NSString stringWithFormat:@"%d",pageIndex]];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd hh:mm a"];
    [BookTimeArray addObject: [fmt stringFromDate:[NSDate date]]];
    [fmt release];
    //得到当前章节名称
    NSString* chapterName = nil;
    unsigned long long fileOffset = [mBook offsetWithPage:pageIndex];
    NSUInteger currentChapter = 0;
    NSUInteger fileSize = 0;
    for(;currentChapter<[singleBook.pageSize count];currentChapter++)
    {
        if(fileOffset >= fileSize && fileOffset < (fileSize + [[singleBook.pageSize objectAtIndex:currentChapter] integerValue]))
        {
               break;
        }
    }
    if(currentChapter >= [singleBook.pageSize count])
    {
        currentChapter = 0;
    }
    chapterName = [singleBook.pages objectAtIndex:currentChapter];
    [ChatperArray addObject:chapterName];
    //保存书签
    [ChatperArray writeToFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_chatper.plist"]]  atomically:YES];
    [PageNumArray writeToFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_pagenum.plist"]]  atomically:YES];
    [BookTimeArray writeToFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_booktime.plist"]]  atomically:YES];
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"提示" message:@"添加书签成功" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    return;
}
- (void)updatePageNumberText:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (page != pageNumberLabel.tag) // Only if page number changed
	{
		NSInteger pages = [mBook getPageCount]; // Total pages
        
		NSString *format = NSLocalizedString(@"%d of %d", @"format"); // Format
        
		NSString *number = [NSString stringWithFormat:format, page, pages]; // Text
        
		pageNumberLabel.text = number; // Update the page number label text
        
		pageNumberLabel.tag = page; // Update the last page number tag
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isShowIndex = NO;
    
    currentLight = [UIScreen mainScreen].brightness;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    UIView* aView = [navBar.subviews objectAtIndex:0];
    aView.hidden = NO;
    
    UIToolbar* toolBar = self.navigationController.toolbar;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] init];
    leftBarButtonItem.title = @"返回";
    leftBarButtonItem.target = self;
    leftBarButtonItem.action = @selector(back:);
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    [leftBarButtonItem release];
        
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(doBookmark)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    
    //为toolbar增加按钮
    UIBarButtonItem *one = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play-last.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doPre)] autorelease];  
    UIBarButtonItem *two = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"color.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doFont)] autorelease];    
    UIBarButtonItem *three = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"light.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doColor)] autorelease];
    UIBarButtonItem *four = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play-next.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doNext)] autorelease];
    UIBarButtonItem *five = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"index.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doIndex)] autorelease];
    UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [self setToolbarItems: [NSArray arrayWithObjects: one,flexItem, two,flexItem, three,flexItem, four,flexItem, five, nil]];
    [self.navigationController.toolbar sizeToFit];


    
    isNavHideflage=YES;
    [self.navigationController setNavigationBarHidden:isNavHideflage animated:TRUE];
    [self.navigationController setToolbarHidden:isNavHideflage animated:TRUE];

	
	self.view.backgroundColor = [UIColor clearColor];
	
	pageIndex = 1;
	headView = nil;
    CGRect rect = [[UIScreen mainScreen] bounds];
	bookLabel = [[PageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-40)];
	[self.view addSubview:bookLabel];
    
	mBook = [[KDBook alloc]initWithBook:bookIndex];
    mBook.delegate = self;
	mBook.pageSize = CGSizeMake(bookLabel.frame.size.width-20, bookLabel.frame.size.height-20);//bookLabel.frame.size;
	mBook.textFont = [UIFont systemFontOfSize:18];//bookLabel.font;
    
#define PAGE_NUMBER_WIDTH 96.0f
#define PAGE_NUMBER_HEIGHT 30.0f
#define PAGE_NUMBER_SPACE 40.0f
    
    
    CGFloat numberY = (rect.size.height-40 - (PAGE_NUMBER_HEIGHT + PAGE_NUMBER_SPACE));
    CGFloat numberX = ((self.view.bounds.size.width - PAGE_NUMBER_WIDTH) / 2.0f);
    CGRect numberRect = CGRectMake(numberX, numberY, PAGE_NUMBER_WIDTH, PAGE_NUMBER_HEIGHT);
    
    pageNumberView = [[UIView alloc] initWithFrame:numberRect]; // Page numbers view
    
    pageNumberView.autoresizesSubviews = NO;
    pageNumberView.userInteractionEnabled = NO;
    pageNumberView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    pageNumberView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    
    pageNumberView.layer.cornerRadius = 4.0f;
    pageNumberView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    pageNumberView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.6f].CGColor;
    pageNumberView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pageNumberView.bounds].CGPath;
    pageNumberView.layer.shadowRadius = 2.0f; pageNumberView.layer.shadowOpacity = 1.0f;
    
    CGRect textRect = CGRectInset(pageNumberView.bounds, 4.0f, 2.0f); // Inset the text a bit
    
    pageNumberLabel = [[UILabel alloc] initWithFrame:textRect]; // Page numbers label
    
    pageNumberLabel.autoresizesSubviews = NO;
    pageNumberLabel.autoresizingMask = UIViewAutoresizingNone;
    pageNumberLabel.textAlignment = UITextAlignmentCenter;
    pageNumberLabel.backgroundColor = [UIColor clearColor];
    pageNumberLabel.textColor = [UIColor whiteColor];
    pageNumberLabel.font = [UIFont systemFontOfSize:16.0f];
    pageNumberLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    pageNumberLabel.shadowColor = [UIColor blackColor];
    pageNumberLabel.adjustsFontSizeToFitWidth = YES;
    pageNumberLabel.minimumFontSize = 12.0f;
    
    [pageNumberView addSubview:pageNumberLabel]; // Add label view
    [self.view addSubview:pageNumberView]; // Add page numbers display view
    [self updatePageNumberText:1];
    pageNumberView.hidden = isNavHideflage;
	
	UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, rect.size.height-40, rect.size.width-20, 20)];
	slider.maximumValue = rect.size.width-20;
	slider.minimumValue = 1;
	slider.value = 1;
	slider.alpha = 0.4;
	[slider addTarget:self action:@selector(sliderEvent) forControlEvents:UIControlEventValueChanged];
	bookSlider = [slider retain];
	[self.view addSubview:slider];
	[slider release];
    
    [self performSelector:@selector(showPage) withObject:self afterDelay:0.25];
}

//toolbar的响应事件
-(void) doPre
{
    if ( pageIndex > 1) {
        --pageIndex;
        bookSlider.value = pageIndex;
        NSString* string = [mBook stringWithPage:pageIndex];
        bookLabel.text = string;
        [self updatePageNumberText:pageIndex];
        [self exchangeAnimate:1];
        [self savePlace:pageIndex];
        return ;
    }
}
-(void) doNext
{
    if ( pageIndex < bookSlider.maximumValue) {
        ++pageIndex;
        bookSlider.value = pageIndex;
        NSString* string = [mBook stringWithPage:pageIndex];
        bookLabel.text = string;
        [self updatePageNumberText:pageIndex];
        [self exchangeAnimate:0];
        [self savePlace:pageIndex];
        return ;
    }
}
-(void) doFont
{
    [bookLabel changeColor];
}
-(void) doColor //调节屏幕亮度
{
    currentLight = currentLight -0.1;
    if(currentLight < 0.3)
    {
        currentLight = 1.0;
    }
    [[UIScreen mainScreen] setBrightness: currentLight];
}

-(void) doIndex
{
    RJSingleBook* singleBook = [[RJBookData sharedRJBookData].books objectAtIndex:bookIndex];
    unsigned long long fileOffset = [mBook offsetWithPage:pageIndex];
    NSUInteger currentChapter = 0;
    NSUInteger fileSize = 0;
    for(;currentChapter<[singleBook.pageSize count];currentChapter++)
    {
        if(fileOffset > fileSize && fileOffset < (fileSize + [[singleBook.pageSize objectAtIndex:currentChapter] integerValue]))
        {
            break;
        }
    }

    RJBookIndexViewController *indexVC = [[RJBookIndexViewController alloc]init];
	indexVC.bookIndex = self.bookIndex;
    indexVC.chapterNum = currentChapter;
    indexVC.delegate = self;
    isShowIndex = YES;
	[self.navigationController pushViewController:indexVC animated:YES];
	[indexVC release];
}

- (void)willBack
{
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    isShowIndex = NO;
}

- (void)gotoPage:(NSUInteger) gotoPageNum
{
    if ( gotoPageNum < bookSlider.maximumValue) {
        pageIndex = gotoPageNum;
        bookSlider.value = pageIndex;
        NSString* string = [mBook stringWithPage:pageIndex];
        bookLabel.text = string;
        [self updatePageNumberText:pageIndex];
        [self exchangeAnimate:0];
        [self savePlace:pageIndex];
        return ;
    }
}
- (void)gotoChapter:(NSUInteger) gotoChapterNum
{
    //根据章节得到页数，然后跳到此页
    RJSingleBook* singleBook = [[RJBookData sharedRJBookData].books objectAtIndex:bookIndex];
    NSUInteger fileSize = 0;
    for(NSUInteger i=0;i<gotoChapterNum;i++)
    {
        fileSize += [[singleBook.pageSize objectAtIndex:i] integerValue];
    }

    NSUInteger tempPage = 1;
    unsigned long long fileOffset;
    for(;tempPage<bookSlider.maximumValue;tempPage++)
    {
        fileOffset = [mBook offsetWithPage:tempPage];
        if(fileOffset > fileSize)
        {
            tempPage--;
            break;
        }
    }
    [self gotoPage:tempPage];
}



- (void)dealloc {
    NSLog(@"KDBookViewController dealloc");
	[headView release];
	[bookSlider release];
	mBook.delegate = nil;
	[mBook release];
	mBook = nil;
	[bookLabel release];
    [pageNumberView release];
    [pageNumberLabel release];
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(showPage) object:nil];
    [super dealloc];
}

-(void) showPage
{
    //从持久化存储读取上次阅读位置,跳到上次所看的页面
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    RJSingleBook* singleBook = [[RJBookData sharedRJBookData].books objectAtIndex:bookIndex];
    NSUInteger lastPage = [saveDefaults integerForKey:singleBook.name];
    if(lastPage == 0) lastPage = 1;
    pageIndex = lastPage;
    if(pageIndex > 1)
    {
        pageIndex = lastPage;
        bookSlider.value = pageIndex;
        NSString* string = [mBook stringWithPage:pageIndex];
        if(string)
        {
            NSLog(@"show text");
            bookLabel.text = string;
            //[self updatePageNumberText:pageIndex];
        }
        else
        {
            NSLog(@"book text = nil");
            [self performSelector:@selector(showPage) withObject:self afterDelay:0.25];
        }
    }
}

- (void)firstPage:(NSString *)pageString{
    if( pageIndex > 1)
    {
        return;
    }
	if (pageString) {
		bookLabel.text = pageString;
	}
}

- (void)bookDidRead:(NSUInteger)size{
	bookSlider.maximumValue = size;
	bookSlider.value = pageIndex;
    [self updatePageNumberText:pageIndex];
}


@end
