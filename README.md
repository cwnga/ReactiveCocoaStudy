# ReactiveCocoaStudy
ReactiveCocoaStudy

# ch1

## 1. rac_textSignal 

    [self.textField.rac_textSignal subscribeNext:^(id input) {
        NSLog(@"input:%@", input);
    }];

## 2. add filter: ex input.lenght >= 2

    [[self.textField.rac_textSignal filter:^BOOL(NSString * input) {
        return input.length >= 2;
    }] subscribeNext:^(id input) {
        NSLog(@"input:%@", input);
    }];

## 3. throttle

    [[[self.textField.rac_textSignal filter:^BOOL(NSString * input) {
        return input.length >= 2;
    }] throttle:0.6f
      ] subscribeNext:^(id input) {
        NSLog(@"input:%@", input);
    }];
## 4. call RACSignal createSignal -> use flattenMap to chagen signal
### [RACSignal createSignal:];

    - (RACSignal *)signalForQuery:(NSString *)query
    {
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSString *q = [[NSString stringWithFormat:@"SELECT * FROM ecsearch.std.search (0, 10) WHERE keyword=\"%@\" and property=\"auction\" and sortBy=\"price\" and sortOrder=\"asc\"", query] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
            NSString *urlString = [NSString stringWithFormat:@"https://auction.yql.yahoo.com/v1/public/yql?q=%@&format=json", q];
    
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"data:%@", data);
                NSLog(@"response:%@", response);
                NSLog(@"error:%@", error);
                if (error) {
                    [subscriber sendError:error];
                } else {
                    NSError *jsonError;
                    id json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    if (jsonError) {
                        [subscriber sendError:jsonError];
                    } else {
                        [subscriber sendNext:json];
                    }
                }
                [subscriber sendCompleted];
            }];
            [dataTask resume];
    
            return [RACDisposable disposableWithBlock:^{
                [dataTask cancel];
            }];
        }];
        return signal;
    }

### flattenMap to chagen signal
    [[[[self.textField.rac_textSignal
        filter:^BOOL(NSString * input) {
            return input.length >= 2;
        }] throttle:0.6f
       ] flattenMap:^RACStream *(NSString *value) {
        return [self signalForQuery:value];
    }] subscribeNext:^(id input) {
        NSLog(@"input:%@", input); //will change to api response
    }];

##ch2 
### case 1: deliverOn:[RACScheduler mainThreadScheduler]] for updateing UI

   [[[[[self.textField.rac_textSignal
         filter:^BOOL(NSString * input) {
             return input.length >= 2;
         }] throttle:0.6f
        ] flattenMap:^RACStream *(NSString *value) {
        return [self signalForQuery:value];
    }] deliverOn:[RACScheduler mainThreadScheduler]]  //update UI need on main thread
     subscribeNext:^(id input) {
         self.data = [input valueForKeyPath:@"query.results.product"];
         NSLog(@"input:%@", input); //will change to api response
         [self.collectionView reloadData];
     }];


### case 2: bind data to update

    ///NOTE: Bind data to update
    [[[[self.textField.rac_textSignal
        filter:^BOOL(NSString * input) {
            return input.length >= 2;
        }] throttle:0.6f
       ] flattenMap:^RACStream *(NSString *value) {
        return [self signalForQuery:value];
    }]
     subscribeNext:^(id input) {
         self.data = [input valueForKeyPath:@"query.results.product"];
         NSLog(@"input:%@", input); //will change to api response
         //[self.collectionView reloadData]; //DELETE for data as signal
     }];

    //data as signal
    RACSignal *dataSignal = [self rac_valuesForKeyPath:@"data" observer:self];
    [[dataSignal deliverOnMainThread ]subscribeNext:^(id x) {
        //update ui in main thread
        [self.collectionView reloadData];
    }];

