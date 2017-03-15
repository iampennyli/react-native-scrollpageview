'use strict';

import React, { Component } from 'react';

import {
    StyleSheet,
    View,
    TouchableOpacity,
    Text,
} from 'react-native';


export default class ScrollBar extends Component {

   constructor(props) {
      super(props);
      this.state = {
         curIndex: 0,
      }
   }

   render() {
      var tabs = this.props.tabs;
      tabs = JSON.parse(tabs);
      return (
         <View style={{flexDirection: 'row',alignItems:'center', ...this.props.style}}>
         {
            tabs.map((value, index) =>(
               <TouchableOpacity key={index} onPress={()=>{
                  this.props.onTabChanged(index);
                  this.setState({
                     curIndex: index,
                  })
               }}>
                  <Text style={{paddingLeft:20, paddingRight:20, color: index==this.state.curIndex ? '#ff0000':'#000000'}}>
                     {value}
                  </Text>
               </TouchableOpacity>
            ))
         }
         </View>
      );
   }
}
