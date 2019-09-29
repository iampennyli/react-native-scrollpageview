## react-native-scrollpageview

Native ios UIScrollView Page Enable mode for React Native

- [Installation](#installation)
- [Examples](#examples)

## Installation
1. `npm install react-native-scrollpageview --save`
2. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
3. add `./node_modules/react-native-scrollpageview/RNScrollPageView.xcodeproj`
4. In the XCode project navigator, select your project, select the `Build Phases` tab and in the `Link Binary With Libraries` section add **libRNScrollPageView.a**
4. And in the `Build Settings` tab in the `Search Paths/Header Search Paths` section add `$(SRCROOT)/../node_modules/react-native-scrollpageview` (make sure it's recursive).
6. `import ScrollPageView from 'react-native-scrollpageview'`

## Examples

#### snapshot

![demo-3](https://media.giphy.com/media/xUPGcFfgjDzQUUjcGY/giphy.gif)

### Easy to use, please see the code

```
'use strict';
import React, { Component } from 'react';

import {
    AppRegistry,
    NativeMethodsMixin,
    NativeModules,
    StyleSheet,
    View,
    Text,
    TouchableOpacity,
    requireNativeComponent,
} from 'react-native';

var ScrollPageView = require('react-native-scrollpageview');

import ScrollBar from './scrollbar'

var Page = ScrollPageView.Page;

export default class ScrollPageViewDemo extends Component {

   constructor(props) {
      super(props);
      this.state = {
         curIndex: 0,
      }
   }

   render () {

      var tabs = ['tab1','tab2', 'tab3', 'tab4', 'tab5'];
      var pages = tabs.map((value, index)=>this.renderPage(value, index));
      
      return (
         <View style={{flex: 1}}>

            {/**fake navigator bar*/}
            <View style={{height: 64, backgroundColor:'#ff0000'}}></View>

            {/**fake test bar*/}
            <ScrollBar style={{height: 40, backgroundColor: '#d5d5d5'}} tabs={JSON.stringify(tabs)} curIndex={this.state.curIndex} onTabChanged={(index)=>{
               this.setState({
                  curIndex: index,
               });
            }}>
            </ScrollBar>

            <ScrollPageView
               style={{flex: 1}}
               curIndex={this.state.curIndex}
               onPageViewDidAppearedAtIndex={(index)=>{
                  this.setState({
                     curIndex: index,
                  })
               }}>
               {pages}
            </ScrollPageView>

         </View>

      );
   }

   renderPage(value, index) {
      return (<Page label={value} renderCell='pageRenderCell' key={index}></Page>);
   }
}


class pageRenderCell extends Component {
   render() {
      return (
         <View style={{flex: 1, justifyContent:'center', alignItems: 'center'}}>
            <Text style={{fontSize: 100}}>{this.props.label}</Text>
         </View>
      );
   }
}

AppRegistry.registerComponent('ScrollPageViewDemo', () => ScrollPageViewDemo);
AppRegistry.registerComponent('pageRenderCell', () => pageRenderCell);
AppRegistry.registerComponent('scrollbar', () => scrollbar);

## Lisence
```
