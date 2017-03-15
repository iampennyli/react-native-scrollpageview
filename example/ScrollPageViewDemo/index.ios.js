/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

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
      return (<Page label={value} renderCell='cell1' key={index}></Page>);
   }
}


class cell1 extends Component {
   render() {
      return (
         <View style={{flex: 1, justifyContent:'center', alignItems: 'center'}}>
            <Text style={{fontSize: 100}}>{this.props.label}</Text>
         </View>
      );
   }
}

AppRegistry.registerComponent('ScrollPageViewDemo', () => ScrollPageViewDemo);
AppRegistry.registerComponent('cell1', () => cell1);
AppRegistry.registerComponent('scrollbar', () => scrollbar);
