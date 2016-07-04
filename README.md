# UUVPagesController
A navigation top bar like "网易新闻" or "今日头条".You just pass viewControllers that display all navigation item in or below UINavigationBar.There are two style for change select index, one is scale and another is show indicator.

### Basic usage
<pre><code>
	#import "UUVPagesController.h"
	
	_pagesController = [UUVPagesController new];
    _pagesController.topBarPlace = self.navigationItem;
    _pagesController.topBarDelegate = self;
    _pagesController.viewControllers = _viewControllers;
    [_pagesController addParentViewController:self];
    	
</code></pre>

### Notes
<ol>
<li>Do not support orientation rotation.</li>
<li>Just support ARC.</li>
<li>If you content behind NavigationBar,you should check out the value of viewController`s edgesForExtendedLayout.</li>
</ol>

### Installation
Latest version: 0.0.4
<pre><code>
pod search UUVPagesController
</code></pre>
if you cannot search out the latest version,try:</br>
<pre><code>
pod setup
</code></pre>

### Release Notes
<li>0.0.3</li>
Add show indicator style and bug fixed.

### License
MIT
