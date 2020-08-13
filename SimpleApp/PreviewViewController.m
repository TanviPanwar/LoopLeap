//
//  PreviewViewController.m
//  SimpleApp
//
//  Created by iOS6 on 18/02/20.
//  Copyright © 2020 MAC. All rights reserved.
//

#import "PreviewViewController.h"
#import "PreviewTableViewCell.h"

@interface PreviewViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    
    
}

@property (weak, nonatomic) IBOutlet UITableView *previewTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalFilesLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedFilesLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedFilesLabel;
@property (weak, nonatomic) IBOutlet UILabel *skipFileslabel;
@property (weak, nonatomic) IBOutlet UILabel *errorFilesLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalUpdateFilesLabel;


@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _totalFilesLabel.text =  [NSString stringWithFormat:@"%@",_totalCount];
    _addedFilesLabel.text = [NSString stringWithFormat:@"%@",_addCount];
    _updatedFilesLabel.text = [NSString stringWithFormat:@"%@",_updateCount];
    _skipFileslabel.text = [NSString stringWithFormat:@"%@",_skipCount];
    _errorFilesLabel.text = [NSString stringWithFormat:@"%@",_errorCount];
    _totalUpdateFilesLabel.text = [NSString stringWithFormat:@"%@",_totalUpdateCount];


    if (_notesArray.count > 0) {
        
        _alertLabel.hidden = YES;
        
    } else {
        
        _alertLabel.hidden = NO;
    }
    
}

#pragma mark- TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _notesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     PreviewTableViewCell *cell = (PreviewTableViewCell *) [self.previewTableView dequeueReusableCellWithIdentifier:@"previewCell" forIndexPath:indexPath];
  
     cell.fileNoLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
     cell.categoryNameLabel.text = _categoryArray[indexPath.row];
     cell.titleLabel.text = _notesArray[indexPath.row];
   
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
