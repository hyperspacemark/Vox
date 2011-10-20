//
//  EditSongViewController.m
//  Vox
//
//  Created by Mark Adams on 10/17/11.
//  Copyright (c) 2011 Interstellar Apps. All rights reserved.
//

#import "EditSongViewController.h"
#import "Song.h"
#import "Artist.h"

@interface EditSongViewController ()

- (void)populateUI;
- (void)updateSaveButtonStatus;

@end

#pragma mark -

@implementation EditSongViewController

@synthesize song;
@synthesize albumArtImageView;
@synthesize titleTextField;
@synthesize artistTextField;
@synthesize lyricsTextView;
@synthesize saveBlock;
@synthesize cancelBlock;
@synthesize saveButton;

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self populateUI];
    [self updateSaveButtonStatus];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        CGRect startingFrame = [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect endingFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve animationCurve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        startingFrame = [self.view convertRect:startingFrame fromView:nil];
        endingFrame = [self.view convertRect:endingFrame fromView:nil];
                
        CGRect viewFrame = self.lyricsTextView.frame;
        viewFrame.size.height = endingFrame.origin.y - viewFrame.origin.y;
        
        [UIView animateWithDuration:duration delay:0.0 options:animationCurve animations:^{
            self.lyricsTextView.frame = viewFrame;
        } completion:nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.titleTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    self.albumArtImageView = nil;
    self.titleTextField = nil;
    self.artistTextField = nil;
    self.lyricsTextView = nil;
    self.saveButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UI Helpers
- (void)populateUI
{
    self.titleTextField.text = self.song.title;
    self.artistTextField.text = self.song.artist.name;
    self.lyricsTextView.text = self.song.lyrics;
}

- (void)updateSaveButtonStatus
{
    BOOL enabled = YES;
    
    if (!self.titleTextField.text.length || !self.artistTextField.text.length || !self.lyricsTextView.hasText)
        enabled = NO;
    
    self.saveButton.enabled = enabled;
}

#pragma mark - Interface Actions
- (IBAction)save:(id)sender
{
    [self.view endEditing:NO];
    self.song.title = self.titleTextField.text;
    self.song.artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.song.managedObjectContext];
    self.song.artist.name = self.artistTextField.text;
    self.song.lyrics = self.lyricsTextView.text;
    self.saveBlock(self.song);
}

- (IBAction)cancel:(id)sender
{
    [self.view endEditing:NO];
    
    if (!self.song.title)
        [self.song.managedObjectContext deleteObject:self.song];
    
    self.cancelBlock();
}

- (IBAction)textFieldEditingChanged
{
    [self updateSaveButtonStatus];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self updateSaveButtonStatus];
}

@end
