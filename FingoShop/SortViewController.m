//
//  SortViewController.m
//  FingoShop
//
//  Created by rizenew on 5/17/17.
//  Copyright © 2017 fis. All rights reserved.
//

#import "SortViewController.h"
#import "Constants.h"

@interface SortViewController ()
{
    
   
    
}
@end

@implementation SortViewController
@synthesize filterFlag,sortOptionsArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([filterFlag isEqualToString:@"Filter"])
    {
        
    }
    else{
        
          sortOptionsArray = [[NSArray alloc]initWithObjects:@"Price - High to Low",@"Price - Low to High",@"Position", nil];
    }
    
  
  
   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sortOptionsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        
    }
    if ([filterFlag isEqualToString:@"Filter"])
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[sortOptionsArray objectAtIndex:indexPath.row] objectForKey:@"label"]];
       
        
        
    }
    else{
       cell.textLabel.text = [NSString stringWithFormat:@"%@",[sortOptionsArray objectAtIndex:indexPath.row]];
    }
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _backNavigationSortOption = @"Sorted";
    
  [[NSNotificationCenter defaultCenter]postNotificationName:@"sortProductList" object:[sortOptionsArray objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
    
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
