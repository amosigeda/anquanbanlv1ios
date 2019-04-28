//
//  IQActionSheetPickerView.m
// https://github.com/hackiftekhar/IQActionSheetPickerView
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "IQActionSheetPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "IQActionSheetViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "Masonry.h"
@interface IQActionSheetPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView    *_pickerView;
    UIDatePicker    *_datePicker;
    UIToolbar       *_actionToolbar;
    UILabel         *_titleLabel;
    NSUserDefaults *defaults;
    NSMutableArray *array;
    DataManager *manager;
    UIView* _view;
    DeviceModel *model;
    IQActionSheetViewController *_actionSheetController;
}

@end

@implementation IQActionSheetPickerView

@synthesize actionSheetPickerStyle  = _actionSheetPickerStyle;
@synthesize titlesForComponents     = _titlesForComponents;
@synthesize widthsForComponents     = _widthsForComponents;
@synthesize isRangePickerView       = _isRangePickerView;
@synthesize delegate                = _delegate;
@synthesize date                    = _date;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<IQActionSheetPickerViewDelegate>)delegate
{
    self = [super initWithFrame:CGRectZero];
    manager = [DataManager shareInstance];
    defaults = [NSUserDefaults standardUserDefaults];
    
    array =   [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    if (self)
    {
        //UIToolbar
        {
            _view = [[UIView alloc]initWithFrame: CGRectMake(0, 0,([UIScreen mainScreen].bounds.size.width), 44)];
            _actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, 0,([UIScreen mainScreen].bounds.size.width), 44)];
            _actionToolbar.barStyle = UIBarStyleDefault;
            [_actionToolbar sizeToFit];
            
            CGRect toolbarFrame = _actionToolbar.frame;
            toolbarFrame.size.height = 44;
            _actionToolbar.frame = toolbarFrame;
            
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            
            //            btn1
            //  Create a fake button to maintain flexibleSpace between cancelButton and titleLabel.(Otherwise the titleLabel will lean to the left）
            UIBarButtonItem *leftNilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            //            [items addObject:leftNilButton];
            
            //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pickerCancelClicked:)];
            [items addObject:cancelButton];
            //  Create a title label to show on toolBar for the title you need.
            _titleLabel = [[UILabel alloc] init];
            //            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (_actionToolbar.frame.size.width-66-57.0-16), 44)];
            _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
            [_titleLabel setBackgroundColor:[UIColor clearColor]];
            [_titleLabel setTextAlignment:NSTextAlignmentCenter];
            [_titleLabel setText:title];
            [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            
            UIBarButtonItem *titlebutton = [[UIBarButtonItem alloc] initWithCustomView:_titleLabel];
            titlebutton.enabled = NO;
            [items addObject:titlebutton];
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            UIBarButtonItem *rightNilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            //            [items addObject:rightNilButton];
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked:)];
            [items addObject:doneButton];
            _view.UserInteractionEnabled = YES;
//            [_view setUserInteractionEnabled:YES];
            UIButton* leftButton = [[UIButton alloc]init];
            UIButton* rightButton = [[UIButton alloc]init];
            //            lab.text = @"quxiao";
            [leftButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
            [rightButton setTitle:NSLocalizedString(@"finish", nil) forState:UIControlStateNormal];
            [leftButton setTitleColor:self.tintColor   forState:UIControlStateNormal];
            [rightButton setTitleColor:self.tintColor forState:UIControlStateNormal];
            [leftButton addTarget:self action:@selector(pickerCancelClicked:) forControlEvents:UIControlEventTouchDown];
            [rightButton addTarget:self action:@selector(pickerDoneClicked:) forControlEvents:UIControlEventTouchDown];
            [_view addSubview:leftButton];
            [_view addSubview:rightButton];
            [_view addSubview:_titleLabel];
            [leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_view.mas_top);
                make.left.equalTo(_view.mas_left).offset(10);
                make.bottom.equalTo(_view.mas_bottom);
            }];
            [rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_view.mas_top);
                make.right.equalTo(_view.mas_right).offset(-10);
                make.bottom.equalTo(_view.mas_bottom);
            }];
            [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(_view);
            }];
            //            CGFloat w2=  rightNilButton.width;
            //            CGFloat w1 = leftNilButton.width;
            //  Adding button to toolBar.
            [_actionToolbar setItems:items];
            _actionToolbar.backgroundColor = [UIColor whiteColor];
            //            _actionToolbar.items
//                        [self addSubview:_actionToolbar];
            //            [self addSubview:_view];
        }
        
        //UIPickerView
        {
            _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44 , [UIScreen mainScreen].bounds.size.width, 216)];
            [_pickerView setUserInteractionEnabled:YES];
            _pickerView.backgroundColor = [UIColor whiteColor];
            [_pickerView setShowsSelectionIndicator:YES];
            [_pickerView setDelegate:self];
            [_pickerView setDataSource:self];
            [self addSubview:_pickerView];
            [self addSubview:_view];
        }
        
        //UIDatePicker
        {
            _datePicker = [[UIDatePicker alloc] initWithFrame:_pickerView.frame];
            [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            _datePicker.frame = _pickerView.frame;
            NSDateFormatter *formater =[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy/MM/dd"];
            _datePicker.maximumDate = [NSDate date];
            if(model.Birthday.length == 0)
            {
                [_datePicker setDate:[NSDate date]];
                
            }
            else if([formater dateFromString:model.Birthday]){
                [_datePicker setDate:[formater dateFromString:model.Birthday]];
                
            }else{
                [_datePicker setDate:[NSDate date]];
            }
            
            [_datePicker setDatePickerMode:UIDatePickerModeDate];
            [self addSubview:_datePicker];
        }
        
        //Initial settings
        {
            self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
            [self setFrame:CGRectMake(0, 0, CGRectGetWidth(_pickerView.frame), CGRectGetMaxY(_pickerView.frame))];
            [self setActionSheetPickerStyle:IQActionSheetPickerStyleTextPicker];
            
            self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            _actionToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
    }
    
    _delegate = delegate;
    _getToolbarTintColor = _actionToolbar.barTintColor;
    return self;
}

-(void)setActionSheetPickerStyle:(IQActionSheetPickerStyle)actionSheetPickerStyle
{
    _actionSheetPickerStyle = actionSheetPickerStyle;
    
    switch (actionSheetPickerStyle) {
        case IQActionSheetPickerStyleTextPicker:
            [_pickerView setHidden:NO];
            [_datePicker setHidden:YES];
            break;
        case IQActionSheetPickerStyleDatePicker:
            [_pickerView setHidden:YES];
            [_datePicker setHidden:NO];
            [_datePicker setDatePickerMode:UIDatePickerModeDate];
            break;
        case IQActionSheetPickerStyleDateTimePicker:
            [_pickerView setHidden:YES];
            [_datePicker setHidden:NO];
            [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
            break;
        case IQActionSheetPickerStyleTimePicker:
            [_pickerView setHidden:YES];
            [_datePicker setHidden:NO];
            [_datePicker setDatePickerMode:UIDatePickerModeTime];
            break;
            
        default:
            break;
    }
}

/**
 *  Set Action Bar Color
 *
 *  @param barColor Custom color for toolBar
 */
-(void)setToolbarTintColor:(UIColor *)barColor{
    
    [_actionToolbar setBarTintColor:barColor];
}

/**
 *  Set Action Tool Bar Button Color
 *
 *  @param buttonColor Custom color for toolBar button
 */
-(void)setToolbarButtonColor:(UIColor *)buttonColor{
    
    [_actionToolbar setTintColor:buttonColor];
}

#pragma mark - Done/Cancel

-(void)pickerCancelClicked:(id)barButton
{
    if ([self.delegate respondsToSelector:@selector(actionSheetPickerViewWillCancel:)])
    {
        [self.delegate actionSheetPickerViewWillCancel:self];
    }
    
    [self dismissWithCompletion:^{
        
        if ([self.delegate respondsToSelector:@selector(actionSheetPickerViewDidCancel:)])
        {
            [self.delegate actionSheetPickerViewDidCancel:self];
        }
    }];
}

-(void)pickerDoneClicked:(id)barButton
{
    switch (_actionSheetPickerStyle)
    {
        case IQActionSheetPickerStyleTextPicker:
        {
            NSMutableArray *selectedTitles = [[NSMutableArray alloc] init];
            
            for (NSInteger component = 0; component<_pickerView.numberOfComponents; component++)
            {
                NSInteger row = [_pickerView selectedRowInComponent:component];
                
                if (row!= -1)
                {
                    [selectedTitles addObject:_titlesForComponents[component][row]];
                }
                else
                {
                    [selectedTitles addObject:[NSNull null]];
                }
            }
            
            [self setSelectedTitles:selectedTitles];
            
            if ([self.delegate respondsToSelector:@selector(actionSheetPickerView:didSelectTitles:)])
            {
                [self.delegate actionSheetPickerView:self didSelectTitles:selectedTitles];
            }
            
        }
            break;
        case IQActionSheetPickerStyleDatePicker:
        case IQActionSheetPickerStyleDateTimePicker:
        case IQActionSheetPickerStyleTimePicker:
        {
            [self setDate:_datePicker.date];
            
            [self setSelectedTitles:@[_datePicker.date]];
            
            if ([self.delegate respondsToSelector:@selector(actionSheetPickerView:didSelectDate:)])
            {
                [self.delegate actionSheetPickerView:self didSelectDate:_datePicker.date];
            }
        }
            
        default:
            break;
    }
    
    [self dismiss];
}

#pragma mark - IQActionSheetPickerStyleDatePicker / IQActionSheetPickerStyleDateTimePicker / IQActionSheetPickerStyleTimePicker

-(void)dateChanged:(UIDatePicker*)datePicker
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) setDate:(NSDate *)date
{
    [self setDate:date animated:NO];
}

-(void)setDate:(NSDate *)date animated:(BOOL)animated
{
    _date = date;
    if (_date != nil)   [_datePicker setDate:_date animated:animated];
}

-(void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
    
    _datePicker.minimumDate = minimumDate;
}

-(void)setMaximumDate:(NSDate *)maximumDate
{
    _maximumDate = maximumDate;
    
    _datePicker.maximumDate = maximumDate;
}

#pragma mark - IQActionSheetPickerStyleTextPicker

-(void)reloadComponent:(NSInteger)component
{
    [_pickerView reloadComponent:component];
}

-(void)reloadAllComponents
{
    [_pickerView reloadAllComponents];
}

-(void)setSelectedTitles:(NSArray *)selectedTitles
{
    [self setSelectedTitles:selectedTitles animated:NO];
}

-(NSArray *)selectedTitles
{
    if (_actionSheetPickerStyle == IQActionSheetPickerStyleTextPicker)
    {
        NSMutableArray *selectedTitles = [[NSMutableArray alloc] init];
        
        NSUInteger totalComponent = _pickerView.numberOfComponents;
        
        for (NSInteger component = 0; component<totalComponent; component++)
        {
            NSInteger selectedRow = [_pickerView selectedRowInComponent:component];
            
            if (selectedRow == -1)
            {
                [selectedTitles addObject:[NSNull null]];
            }
            else
            {
                NSArray *items = _titlesForComponents[component];
                
                if ([items count] > selectedRow)
                {
                    id selectTitle = items[selectedRow];
                    [selectedTitles addObject:selectTitle];
                }
                else
                {
                    [selectedTitles addObject:[NSNull null]];
                }
            }
        }
        
        return selectedTitles;
    }
    else
    {
        return nil;
    }
}

-(void)setSelectedTitles:(NSArray *)selectedTitles animated:(BOOL)animated
{
    if (_actionSheetPickerStyle == IQActionSheetPickerStyleTextPicker)
    {
        NSUInteger totalComponent = MIN(selectedTitles.count, _pickerView.numberOfComponents);
        
        for (NSInteger component = 0; component<totalComponent; component++)
        {
            NSArray *items = _titlesForComponents[component];
            id selectTitle = selectedTitles[component];
            
            if ([items containsObject:selectTitle])
            {
                NSUInteger rowIndex = [items indexOfObject:selectTitle];
                [_pickerView selectRow:rowIndex inComponent:component animated:animated];
            }
        }
    }
}

- (void)setSelectedIndex:(NSString *)str andNSArray:(NSArray *)nsarray
{
    if (_actionSheetPickerStyle == IQActionSheetPickerStyleTextPicker)
    {
        for (int i = 0; i < nsarray.count;i++)
        {
            if([str isEqualToString:[nsarray objectAtIndex:i]])
            {
                [_pickerView selectRow:i inComponent:0 animated:YES];
                
            }
        }
    }
}

- (void)changeIndex:(NSInteger)row
{
    
    [_pickerView selectRow:row inComponent:0 animated:YES];
    
}


-(void)selectIndexes:(NSArray *)indexes animated:(BOOL)animated
{
    if (_actionSheetPickerStyle == IQActionSheetPickerStyleTextPicker)
    {
        NSUInteger totalComponent = MIN(indexes.count, _pickerView.numberOfComponents);
        
        for (NSInteger component = 0; component<totalComponent; component++)
        {
            NSArray *items = _titlesForComponents[component];
            NSUInteger selectIndex = [indexes[component] unsignedIntegerValue];
            
            if (selectIndex < items.count)
            {
                [_pickerView selectRow:selectIndex inComponent:component animated:animated];
            }
        }
    }
}

#pragma mark - UIPickerView delegate/dataSource

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    //If having widths
    if (_widthsForComponents)
    {
        //If object isKind of NSNumber class
        if ([_widthsForComponents[component] isKindOfClass:[NSNumber class]])
        {
            CGFloat width = [_widthsForComponents[component] floatValue];
            
            //If width is 0, then calculating it's size.
            if (width == 0)
                return ((pickerView.bounds.size.width-20)-2*(_titlesForComponents.count-1))/_titlesForComponents.count;
            //Else returning it's width.
            else
                return width;
        }
        //Else calculating it's size.
        else
            return ((pickerView.bounds.size.width-20)-2*(_titlesForComponents.count-1))/_titlesForComponents.count;
    }
    //Else calculating it's size.
    else
    {
        return ((pickerView.bounds.size.width-20)-2*(_titlesForComponents.count-1))/_titlesForComponents.count;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [_titlesForComponents count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_titlesForComponents[component] count];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *labelText = [[UILabel alloc] init];
    if(self.titleFont == nil){
        labelText.font = [UIFont boldSystemFontOfSize:20.0];
    }else{
        labelText.font = self.titleFont;
    }
    labelText.backgroundColor = [UIColor clearColor];
    [labelText setTextAlignment:NSTextAlignmentCenter];
    [labelText setText:_titlesForComponents[component][row]];
    return labelText;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_isRangePickerView && pickerView.numberOfComponents == 3)
    {
        if (component == 0)
        {
            [pickerView selectRow:MAX([pickerView selectedRowInComponent:2], row) inComponent:2 animated:YES];
        }
        else if (component == 2)
        {
            [pickerView selectRow:MIN([pickerView selectedRowInComponent:0], row) inComponent:0 animated:YES];
        }
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if ([self.delegate respondsToSelector:@selector(actionSheetPickerView:didChangeRow:inComponent:)]) {
        [self.delegate actionSheetPickerView:self didChangeRow:row inComponent:component];
    }
}

#pragma mark - show/Hide

-(void)dismiss
{
    [_actionSheetController dismissWithCompletion:nil];
}

-(void)dismissWithCompletion:(void (^)(void))completion
{
    [_actionSheetController dismissWithCompletion:completion];
}

-(void)show
{
    [self showWithCompletion:nil];
}

-(void)showWithCompletion:(void (^)(void))completion
{
    [_pickerView reloadAllComponents];
    
    _actionSheetController = [[IQActionSheetViewController alloc] init];
    [_actionSheetController showPickerView:self completion:completion];
}


@end

