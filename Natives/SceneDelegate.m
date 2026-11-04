#import "SceneDelegate.h"
#import "ios_uikit_bridge.h"
#import "utils.h"

extern UIWindow *mainWindow;

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)applyNiyoLuxuryAppearance {
    UIColor *background = [UIColor colorWithRed:0.018 green:0.014 blue:0.035 alpha:1.0];
    UIColor *surface = [UIColor colorWithRed:0.055 green:0.040 blue:0.090 alpha:1.0];
    UIColor *violet = [UIColor colorWithRed:0.62 green:0.30 blue:1.0 alpha:1.0];
    UIColor *gold = [UIColor colorWithRed:0.96 green:0.70 blue:0.24 alpha:1.0];

    UINavigationBarAppearance *navigation = [UINavigationBarAppearance new];
    [navigation configureWithOpaqueBackground];
    navigation.backgroundColor = surface;
    navigation.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    navigation.largeTitleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    navigation.shadowColor = [UIColor colorWithRed:0.62 green:0.30 blue:1.0 alpha:0.32];
    UINavigationBar *navigationBar = UINavigationBar.appearance;
    navigationBar.standardAppearance = navigation;
    navigationBar.scrollEdgeAppearance = navigation;
    navigationBar.compactAppearance = navigation;
    navigationBar.tintColor = violet;
    navigationBar.barStyle = UIBarStyleBlack;

    UIToolbarAppearance *toolbar = [UIToolbarAppearance new];
    [toolbar configureWithOpaqueBackground];
    toolbar.backgroundColor = surface;
    toolbar.shadowColor = [UIColor colorWithRed:0.62 green:0.30 blue:1.0 alpha:0.28];
    UIToolbar *toolbarAppearance = UIToolbar.appearance;
    toolbarAppearance.standardAppearance = toolbar;
    if (@available(iOS 15.0, *)) {
        toolbarAppearance.scrollEdgeAppearance = toolbar;
    }
    toolbarAppearance.compactAppearance = toolbar;
    toolbarAppearance.tintColor = violet;
    toolbarAppearance.barStyle = UIBarStyleBlack;

    UITableView.appearance.backgroundColor = background;
    UITableView.appearance.separatorColor = [UIColor colorWithRed:0.42 green:0.30 blue:0.62 alpha:0.30];
    UITableViewCell.appearance.backgroundColor = UIColor.clearColor;
    UISwitch.appearance.onTintColor = violet;
    UISegmentedControl.appearance.selectedSegmentTintColor = [UIColor colorWithRed:0.34 green:0.16 blue:0.58 alpha:1.0];
    UISegmentedControl.appearance.backgroundColor = surface;
    UIPageControl.appearance.currentPageIndicatorTintColor = gold;
    UIPageControl.appearance.pageIndicatorTintColor = [gold colorWithAlphaComponent:0.28];
    UISlider.appearance.minimumTrackTintColor = violet;
    UISlider.appearance.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.18];
    UIActivityIndicatorView.appearance.color = violet;
    UIButton.appearance.tintColor = violet;
    UILabel.appearance.textColor = UIColor.whiteColor;
    UITextField.appearance.tintColor = violet;
    UITextView.appearance.tintColor = violet;
    UIView.appearance.tintColor = violet;

    self.window.backgroundColor = background;
    self.window.tintColor = violet;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    [self applyNiyoLuxuryAppearance];
    mainWindow = self.window;
    launchInitialViewController(self.window);
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Resume app work when the scene becomes active.
}

- (void)sceneWillResignActive:(UIScene *)scene {
    // The scene is about to become inactive.
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // The scene is entering the foreground.
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    CallbackBridge_pauseGameIfNeed();
}

@end
