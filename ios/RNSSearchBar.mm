#import <UIKit/UIKit.h>

#import "RNSSearchBar.h"

#import <React/RCTBridge.h>
#import <React/RCTComponent.h>
#import <React/RCTUIManager.h>

#ifdef RN_FABRIC_ENABLED
#import <React/RCTConversions.h>
#import <react/renderer/components/rnscreens/ComponentDescriptors.h>
#import <react/renderer/components/rnscreens/EventEmitters.h>
#import <react/renderer/components/rnscreens/Props.h>
#import <react/renderer/components/rnscreens/RCTComponentViewHelpers.h>
#import "RCTFabricComponentsPlugins.h"
#import "RNSConvert.h"
#endif

@implementation RNSSearchBar {
  __weak RCTBridge *_bridge;
  UISearchController *_controller;
  UIColor *_textColor;
}

@synthesize controller = _controller;

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  if (self = [super init]) {
    _bridge = bridge;
    [self initCommonProps];
  }
  return self;
}

#ifdef RN_FABRIC_ENABLED
- (instancetype)init
{
  if (self = [super init]) {
    static const auto defaultProps = std::make_shared<const facebook::react::RNSSearchBarProps>();
    _props = defaultProps;
    [self initCommonProps];
  }
  return self;
}
#endif

- (void)initCommonProps
{
  _controller = [[UISearchController alloc] initWithSearchResultsController:nil];
  _controller.searchBar.delegate = self;
  _hideWhenScrolling = YES;
}

- (void)setObscureBackground:(BOOL)obscureBackground
{
  if (@available(iOS 9.1, *)) {
    [_controller setObscuresBackgroundDuringPresentation:obscureBackground];
  }
}

- (void)setHideNavigationBar:(BOOL)hideNavigationBar
{
  [_controller setHidesNavigationBarDuringPresentation:hideNavigationBar];
}

- (void)setHideWhenScrolling:(BOOL)hideWhenScrolling
{
  _hideWhenScrolling = hideWhenScrolling;
}

- (void)setAutoCapitalize:(UITextAutocapitalizationType)autoCapitalize
{
  [_controller.searchBar setAutocapitalizationType:autoCapitalize];
}

- (void)setPlaceholder:(NSString *)placeholder
{
  [_controller.searchBar setPlaceholder:placeholder];
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && defined(__IPHONE_13_0) && \
    __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0 && !TARGET_OS_TV
  if (@available(iOS 13.0, *)) {
    [_controller.searchBar.searchTextField setBackgroundColor:barTintColor];
  }
#endif
}

- (void)setTintColor:(UIColor *)tintColor
{
  [_controller.searchBar setTintColor:tintColor];
}

- (void)setTextColor:(UIColor *)textColor
{
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && defined(__IPHONE_13_0) && \
    __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0 && !TARGET_OS_TV
  _textColor = textColor;
  if (@available(iOS 13.0, *)) {
    [_controller.searchBar.searchTextField setTextColor:_textColor];
  }
#endif
}

- (void)setCancelButtonText:(NSString *)text
{
  [_controller.searchBar setValue:text forKey:@"cancelButtonText"];
}

- (void)hideCancelButton
{
#if !TARGET_OS_TV
  if (@available(iOS 13, *)) {
    // On iOS 13+ UISearchController automatically shows/hides cancel button
    // https://developer.apple.com/documentation/uikit/uisearchcontroller/3152926-automaticallyshowscancelbutton?language=objc
  } else {
    [_controller.searchBar setShowsCancelButton:NO animated:YES];
  }
#endif
}

- (void)showCancelButton
{
#if !TARGET_OS_TV
  if (@available(iOS 13, *)) {
    // On iOS 13+ UISearchController automatically shows/hides cancel button
    // https://developer.apple.com/documentation/uikit/uisearchcontroller/3152926-automaticallyshowscancelbutton?language=objc
  } else {
    [_controller.searchBar setShowsCancelButton:YES animated:YES];
  }
#endif
}

#pragma mark delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && defined(__IPHONE_13_0) && \
    __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0 && !TARGET_OS_TV
  if (@available(iOS 13.0, *)) {
    // for some reason, the color does not change when set at the beginning,
    // so we apply it again here
    if (_textColor != nil) {
      [_controller.searchBar.searchTextField setTextColor:_textColor];
    }
  }
#endif

  [self showCancelButton];
  [self becomeFirstResponder];
#ifdef RN_FABRIC_ENABLED
#else
  if (self.onFocus) {
    self.onFocus(@{});
  }
#endif
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
#ifdef RN_FABRIC_ENABLED
#else
  if (self.onBlur) {
    self.onBlur(@{});
  }
#endif
  [self hideCancelButton];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
#ifdef RN_FABRIC_ENABLED
#else
  if (self.onChangeText) {
    self.onChangeText(@{
      @"text" : _controller.searchBar.text,
    });
  }
#endif
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
#ifdef RN_FABRIC_ENABLED
#else
  if (self.onSearchButtonPress) {
    self.onSearchButtonPress(@{
      @"text" : _controller.searchBar.text,
    });
  }
#endif
}

#if !TARGET_OS_TV
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  _controller.searchBar.text = @"";
  [self resignFirstResponder];
  [self hideCancelButton];

#ifdef RN_FABRIC_ENABLED
#else
  if (self.onCancelButtonPress) {
    self.onCancelButtonPress(@{});
  }
  if (self.onChangeText) {
    self.onChangeText(@{
      @"text" : _controller.searchBar.text,
    });
  }
#endif // RN_FABRIC_ENABLED
}
#endif // !TARGET_OS_TV

#pragma mark-- Fabric specific

#ifdef RN_FABRIC_ENABLED
- (void)updateProps:(facebook::react::Props::Shared const &)props
           oldProps:(facebook::react::Props::Shared const &)oldProps
{
  const auto &oldScreenProps = *std::static_pointer_cast<const facebook::react::RNSSearchBarProps>(_props);
  const auto &newScreenProps = *std::static_pointer_cast<const facebook::react::RNSSearchBarProps>(props);

  [self setHideWhenScrolling:newScreenProps.hideWhenScrolling];

  if (oldScreenProps.cancelButtonText != newScreenProps.cancelButtonText) {
    [self setCancelButtonText:RCTNSStringFromStringNilIfEmpty(newScreenProps.cancelButtonText)];
  }

  if (oldScreenProps.obscureBackground != newScreenProps.obscureBackground) {
    [self setObscureBackground:newScreenProps.obscureBackground];
  }

  if (oldScreenProps.hideNavigationBar != newScreenProps.hideNavigationBar) {
    [self setHideNavigationBar:newScreenProps.hideNavigationBar];
  }

  if (oldScreenProps.placeholder != newScreenProps.placeholder) {
    [self setPlaceholder:RCTNSStringFromStringNilIfEmpty(newScreenProps.placeholder)];
  }

  if (oldScreenProps.autoCapitalize != newScreenProps.autoCapitalize) {
    [self setAutoCapitalize:[RNSConvert UITextAutocapitalizationTypeFromCppEquivalent:newScreenProps.autoCapitalize]];
  }

  [super updateProps:props oldProps:oldProps];
}

+ (facebook::react::ComponentDescriptorProvider)componentDescriptorProvider
{
  return facebook::react::concreteComponentDescriptorProvider<facebook::react::RNSSearchBarComponentDescriptor>();
}

#else
#endif

@end

#ifdef RN_FABRIC_ENABLED
Class<RCTComponentViewProtocol> RNSSearchBarCls(void)
{
  return RNSSearchBar.class;
}
#endif

@implementation RNSSearchBarManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[RNSSearchBar alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(obscureBackground, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideNavigationBar, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideWhenScrolling, BOOL)
RCT_EXPORT_VIEW_PROPERTY(autoCapitalize, UITextAutocapitalizationType)
RCT_EXPORT_VIEW_PROPERTY(placeholder, NSString)
RCT_EXPORT_VIEW_PROPERTY(barTintColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(textColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(cancelButtonText, NSString)

RCT_EXPORT_VIEW_PROPERTY(onChangeText, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCancelButtonPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSearchButtonPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFocus, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onBlur, RCTBubblingEventBlock)

@end
