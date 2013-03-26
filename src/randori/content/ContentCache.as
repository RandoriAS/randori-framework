/***
 * Copyright 2013 LTN Consulting, Inc. /dba Digital Primates®
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * @author Michael Labriola <labriola@digitalprimates.net>
 */
package randori.content {
	public class ContentCache {
		public static var htmlMergedFiles:Object = new Object();

		public function hasCachedFile( key:String ):Boolean {
			return ( ContentCache.htmlMergedFiles[key] != null );
		}

		public function getCachedFileList():Array {
			var contentList:Array = new Array();
			for each (var key:String in ContentCache.htmlMergedFiles) {
				contentList.push(key);
			}
			
			return contentList;
		}
		
		public function getCachedHtmlForUri(key:String):String {
			if (ContentCache.htmlMergedFiles[key] != null) {
				return ContentCache.htmlMergedFiles[key];
			}
			return null;
		}

		public function ContentCache() {
		}
	}
}