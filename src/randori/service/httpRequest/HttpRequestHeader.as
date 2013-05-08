package randori.service.httpRequest {

[JavaScript(export="false",name="Object",mode="json")]
public class HttpRequestHeader {

    public var header:String;
    public var value:String;

    public function HttpRequestHeader(header:String, value:String) {
        this.header = header;
        this.value  = value;
    }
}
}