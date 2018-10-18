<%
/* =================================================================
 * 작성일 : 2017.06.05
 * 작성자 : 이정윤
 * 상세설명 : 환경 설정 관리 화면( Google 인프라 환경 설정 조회)
 * =================================================================
 * 수정일      작성자      내용     
 * -----------------------------------------------------------------
 * 2017.12    배병욱    Google Public-Key 입력 삭제
 
 * =================================================================
 */ 
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix = "spring" uri = "http://www.springframework.org/tags" %>

<script type="text/javascript">
var configInfo="";
var keyPathFileList ="";
var search_grid_fail_msg = '<spring:message code="common.grid.select.fail"/>';//목록 조회 중 오류가 발생했습니다.
var search_lock_msg = '<spring:message code="common.search.data.lock"/>';//데이터 조회 중 입니다.
var save_lock_msg='<spring:message code="common.save.data.lock"/>';//등록 중 입니다.
var delete_lock_msg='<spring:message code="common.delete.data.lock"/>';//삭제 중 입니다.
var select_fail_msg='<spring:message code="common.grid.selected.fail"/>'//선택된 레코드가 존재하지 않습니다.
var popup_delete_msg='<spring:message code="common.popup.delete.message"/>';//삭제 하시겠습니까?
var text_required_msg='<spring:message code="common.text.vaildate.required.message"/>';//을(를) 입력하세요.
var select_required_msg='<spring:message code="common.select.vaildate.required.message"/>';//을(를) 선택하세요.
var text_injection_msg='<spring:message code="common.text.validate.sqlInjection.message"/>';//입력하신 값은 입력하실 수 없습니다.

$(function() {
    $('#google_configGrid').w2grid({
        name: 'google_configGrid',
        style   : 'text-align:center',
        method  : 'GET',
        multiSelect: false,
        show: {
            selectColumn: true,
            footer: true
            },
        columns : [
           {field: 'id',  caption: 'id', hidden:true}
           , {field: 'accountId', caption: 'accountId',hidden:true}
           , {field: 'iaasConfigAlias', caption: '환경 설정 별칭', size: '100px', style: 'text-align:center'}
           , {field: 'deployStatus', caption: '플랫폼 배포 사용 여부', size: '7%', style: 'text-align:center'}
           , {field: 'accountName', caption: '계정 별칭', size: '100px', style: 'text-align:center'}
           , {field: 'commonSecurityGroup', caption: 'Tag Names', size: '10%', style: 'text-align:left'}
           , {field: 'commonKeypairPath', caption: 'commonKeypairPath', size: '10%', style: 'text-align:left'}
           , {field: 'createUserId', caption: '생성자', hidden:true}
           , {field: 'createDate', caption: '생성 일자', size: '6%', style: 'text-align:center'}
           , {field: 'updateDate', caption: '수정 일자', size: '6%', style: 'text-align:center'}
         ],onError: function(event){
             w2alert(search_grid_fail_msg, "Google 환경 설정 목록");
         },onLoad : function(event){
             
         },onSelect : function(event){
             event.onComplete = function(){
                $("#updateConfigBtn").attr('disabled', false);
                $("#deleteConfigBtn").attr('disabled', false);
            }
         },onUnselect : function(event){
             event.onComplete = function(){
                 $("#updateConfigBtn").attr('disabled', true);
                 $("#deleteConfigBtn").attr('disabled', true);
            }
         }
    });
     doSearch(); 
     
/*************************** *****************************
 * 설명 :  Google 등록 정보 팝업 화면
 *********************************************************/
$("#registConfigBtn").click(function(){
    w2popup.open({
        title   : "<b>Google 환경 설정 등록</b>",
        width   : 650,
        height  : 475,
        modal   : true,
        body    : $("#registPopupDiv").html(),
        buttons : $("#registPopupBtnDiv").html(),
        onOpen : function(event){
            event.onComplete = function(){
               getGoogleAccountName();
               //키파일정보 리스트
               getKeyPathFileList();
            }                   
        },onClose:function(event){
            w2ui['google_configGrid'].reset();
            initsetting();
            doSearch();
        }
    });
});
     
/*************************** *****************************
 * 설명 :  Google 정보 수정 팝업 화면
 *********************************************************/
 $("#updateConfigBtn").click(function(){
     if($("#updateConfigBtn").attr('disabled') == "disabled") return;
     w2popup.open({
            title   : "<b>Google 환경 설정 수정</b>",
            width   : 650,
            height  : 475,
            modal   : true,
            body    : $("#registPopupDiv").html(),
            buttons : $("#updatePopupBtnDiv").html(),
            onOpen : function(event){
                event.onComplete = function(){
                     var selected = w2ui['google_configGrid'].getSelection();
                     if( selected.length == 0 ){
                         w2alert('<spring:message code="common.grid.selected.fail"/>', "Google 환경 설정 수정");
                         return;
                     }
                     var record = w2ui['google_configGrid'].get(selected);
                     setGoogleDetailInfo(record.id);
                }
            },onClose:function(event){
                $("#updateConfigBtn").attr('disabled', true);
                $("#deleteConfigBtn").attr('disabled', true);
                w2ui['google_configGrid'].reset();
                doSearch();
            }
        });
 });
     
/*************************** *****************************
 * 설명 :  Google 정보 삭제 팝업 화면
 *********************************************************/
$("#deleteConfigBtn").click(function(){
  if( $("#deleteConfigBtn").attr("disabled") == "disabled" ) return;
  //grid record
    var selected = w2ui['google_configGrid'].getSelection();
    if( selected.length == 0 ){
        w2alert(select_fail_msg);
        w2ui['google_configGrid'].unlock();
        w2ui['google_configGrid'].reset();
        doSearch();
        return;
    }
    var record = w2ui['google_configGrid'].get(selected);
    var msg = "환경 설정 정보(" + record.iaasConfigAlias + ")"+ popup_delete_msg;
    if( record.deployStatus == '사용중' ){
        msg = "<span style='color:red'>현재 Google 플랫폼 설치에서 <br/>해당 환경 설정 정보("+record.iaasConfigAlias+")를 사용하고 있습니다. </span><br/><span style='color:red; font-weight:bolder'>그래도 삭제 하시겠습니까?</span>";
    }
  w2confirm({
        title        : "<b>Google 환경 설정 정보 삭제<b/>",
        msg          : msg,
        yes_text     : "확인",
        no_text      : "취소",
        yes_callBack : function(event){
            w2ui['google_configGrid'].lock(delete_lock_msg, {
                spinner: true, opacity : 1
            });
            //delete function 호출
            deleteGoogleConfigInfo(record);
            w2ui['google_configGrid'].reset();
        },no_callBack  : function(event){
            w2ui['google_configGrid'].unlock();
            w2ui['google_configGrid'].reset();
            doSearch();
        }
  });
});
});

/****************************************************
 * 기능 : getKeyPathFileList
 * 설명 : 키 파일 정보 조회
 *****************************************************/
function getKeyPathFileList(){
    $.ajax({
        type : "GET",
        url : "/common/deploy/key/list/google",
        contentType : "application/json",
        async : true,
        success : function(data, status) {
            keyPathFileList = data;
            $('.w2ui-msg-body input:radio[name=keyPathType]:input[value=list]').attr("checked", true);  
            changeKeyPathType("list");
        },
        error : function( e, status ) {
            w2alert("KeyPath File 목록을 가져오는데 실패하였습니다.", "BOOTSTRAP 설치");
        }
    });
}

/******************************************************************
 * 기능 : changeKeyPathType
 * 설명 : Private key file 선택
 ***************************************************************** */
function changeKeyPathType(type){
     $(".w2ui-msg-body input[name=commonKeypairPath]").val("");
     $(".w2ui-msg-body input[name=keyPathFileName]").val("");
     //목록에서 선택
     if(type == "list") {
         $('.w2ui-msg-body select[name=keyPathList]').css("borderColor", "#bbb")
         changeKeyPathStyle("#keyPathListDiv", "#keyPathFileDiv");
         
         var options = "<option value=''>키 파일을 선택하세요.</option>";
         for( var i=0; i<keyPathFileList.length; i++ ){
             if( configInfo.commonKeypairPath == keyPathFileList[i] ){
                 options += "<option value='"+keyPathFileList[i]+"' selected='selected'>"+keyPathFileList[i]+"</option>";
                 $(".w2ui-msg-body input[name=commonKeypairPath]").val(keyPathFileList[i]);
             }else{
                 options += "<option value='"+keyPathFileList[i]+"'>"+keyPathFileList[i]+"</option>";
             }
         }
         $('.w2ui-msg-body select[name=keyPathList]').html(options);
     }else{
         //파일업로드
         $('.w2ui-msg-body input[name=keyPathFileName]').css("borderColor", "#bbb")
         changeKeyPathStyle("#keyPathFileDiv", "#keyPathListDiv");
     }
}

/********************************************************
 * 기능 : changeKeyPathStyle
 * 설명 : Json 키 파일 스타일 변경
 *********************************************************/
function changeKeyPathStyle( showDiv, hideDiv ){
     $(".w2ui-msg-body "+ hideDiv).hide();
     $(".w2ui-msg-body "+ hideDiv +" p").remove();
     $(".w2ui-msg-body "+ showDiv).show();
}


/****************************************************
 * 기능 : getGoogleAccountName
 * 설명 : 해당 유저의 인프라에 대한 계정 별칭 목록 조회 요청
*****************************************************/
function getGoogleAccountName(){
    w2popup.lock(search_lock_msg,true);
    $.ajax({
        type : "GET",
        url : "/common/deploy/accountList/google",
        contentType : "application/json",
        success : function(data, status) {
            setupGoogleAccountName(data);
            w2popup.unlock();
        },
        error : function(request, status, error) {
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message, "해당 계정 별칭 목록 조회");
        }
    });
}

/****************************************************
 * 기능 : setupGoogleAccountName
 * 설명 : 해당 유저의 인프라에 대한 계정 별칭 목록 설정
*****************************************************/
function setupGoogleAccountName(data){
     var iaasAccountName = "<select class='form-control select-control' style='width: 300px; margin-left:6px;' name='accountId' onchange='getGoogleZoneList(this.value);'>";
     if( data.length ==0 ){
         iaasAccountName +="<option value=''>계정을 등록하세요.</option>";
     }else{
         for (var i=0; i<data.length; i++){
             if( data[i].id == configInfo.accountId){
                 iaasAccountName +="<option value='"+data[i].id+"' selected>" + data[i].accountName + "</option>";   
             }else{
                 iaasAccountName +="<option value='"+data[i].id+"'>" + data[i].accountName + "</option>";   
             }
         } 
     }
     iaasAccountName+="</select>";
     $(".w2ui-msg-body .accountNameDiv").html(iaasAccountName);
     
     getGoogleZoneList($(".w2ui-msg-body select[name='accountId']").val());
}

/****************************************************
 * 기능 : getGoogleZoneList
 * 설명 : 구글 클라우드 영역 목록 조회 요청
*****************************************************/
function getGoogleZoneList(accountId){
    if( checkEmpty(accountId) ){
        w2alert("인프라 관리 대시보드에서 계정을 등록해주세요.");
    }else{
        w2popup.lock("zone을 "+search_lock_msg,true);
	    $.ajax({
	        type : "GET",
	        url : "/common/google/zone/list/"+accountId,
	        contentType : "application/json",
	        success : function(data, status) {
	            setupGoogleZoneList(data);
	            w2popup.unlock();
	        },
	        error : function(request, status, error) {
	            var errorResult = JSON.parse(request.responseText);
	            w2alert(errorResult.message, "해당 계정 별칭 목록 조회");
	        }
	    });
    }
}

/****************************************************
 * 기능 : setupGoogleZoneListdata
 * 설명 : 구글 클라우드 영역 목록 설정
*****************************************************/
function setupGoogleZoneList(data){
     var options="<option value=''>zone을 선택하세요.</option>";
     for( var i=0; i<data.length; i++ ){
         if( configInfo.commonAvailabilityZone == data[i] ){
             options += "<option value='"+data[i]+"' selected>"+data[i]+"</option>";
         }else{
             
             options += "<option value='"+data[i]+"'>"+data[i]+"</option>";
         }
     }
     $(".w2ui-msg-body select[name='commonAvailabilityZone']").html(options);
}


/****************************************************
 * 기능 : setGoogleDetailInfo
 * 설명 : Google 상세 정보 조회 후 수정 데이터 설정
*****************************************************/
function setGoogleDetailInfo(id){
    $.ajax({
        type : "GET",
        url : "/info/iaasConfig/google/save/detail/"+id,
        contentType : "application/json",
        async : true,
        dataType : "json",
        success : function(data, status) {
             if(data!=null){
                 $(".w2ui-msg-body input[name='iaasConfigAlias']").val(data.iaasConfigAlias);
                 $(".w2ui-msg-body input[name='id']").val(data.id);
                 $(".w2ui-msg-body input[name='accountId']").val(data.accountId);
                 $(".w2ui-msg-body input[name='googleTagNames']").val(data.commonSecurityGroup);
                 $(".w2ui-msg-body input[name='googlePublicKey']").val(data.googlePublicKey);
                 configInfo = { 
                         accountId : data.accountId,
                         commonKeypairPath : data.commonKeypairPath,
                         commonAvailabilityZone : data.commonAvailabilityZone,
                         googlePublicKey : data.googlePublicKey
                 }
             }
             getGoogleAccountName();
             getKeyPathFileList(data.commonAvailabilityZone);
        },
        error : function(request, status, error) {
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message, "Google 환경 정보 수정 실패");
        }
     });
}

/******************************************************************
 * Function : openBrowse
 * 설명 : 공통 File upload Browse Button
 ***************************************************************** */
function openBrowse(){
    $(".w2ui-msg-body input[name='keyPathFile']").click();
}

/****************************************************
 * 기능 : uploadPrivateKey
 * 설명 : Google Private key 업로드
*****************************************************/
function uploadPrivateKey(){
    var form = $(".w2ui-msg-body #googleConfigForm")[0];
    var formData = new FormData(form);
    
    var files = document.getElementsByName('keyPathFile')[0].files;
    formData.append("file", files[0]);
    
    $.ajax({
        type : "POST",
        url : "/common/deploy/key/upload",
        enctype : 'multipart/form-data',
        dataType: "text",
        async : true,
        processData: false, 
        contentType:false,
        data : formData,  
        success : function(data, status) {
            saveGoogleConfigInfo();
        },
        error : function( e, status ) {
            w2alert( "Private Key 업로드에 실패 하였습니다.", "Google 환경 설정 등록");
        }
    });
    
}

/****************************************************
 * 기능 : saveGoogleConfigInfo
 * 설명 : Google 정보 저장
*****************************************************/
function saveGoogleConfigInfo(){
    w2popup.lock(save_lock_msg, true);
    configInfo = {
              iaasType  : "GOOGLE"
             ,accountId : $(".w2ui-msg-body select[name='accountId']").val()
             ,iaasConfigAlias : $(".w2ui-msg-body input[name='iaasConfigAlias']").val()
             ,id : $(".w2ui-msg-body input[name='id']").val()
             ,accountName : $(".w2ui-msg-body input[name='accountName']").val()
             ,commonKeypairPath : $(".w2ui-msg-body input[name='commonKeypairPath']").val()
             ,commonAvailabilityZone : $(".w2ui-msg-body select[name='commonAvailabilityZone']").val()
             ,commonSecurityGroup : $(".w2ui-msg-body input[name='googleTagNames']").val()
             ,googlePublicKey: $(".w2ui-msg-body input[name='googlePublicKey']").val()
     }
     $.ajax({
         type : "PUT",
         url : "/info/iaasConfig/google/save",
         contentType : "application/json",
         async : true,
         data : JSON.stringify(configInfo),
         success : function(status) {
             w2popup.unlock();
             w2popup.close();    
             initsetting();
             w2ui['google_configGrid'].reset();
         },
         error : function(request, status, error) {
             w2popup.unlock();
             var errorResult = JSON.parse(request.responseText);
             w2alert(errorResult.message);
         }
     });
}

/****************************************************
 * 기능 : deleteGoogleConfigInfo
 * 설명 : Google 정보 삭제 요청
*****************************************************/
function deleteGoogleConfigInfo(record){
     configInfo ={
            id :  record.id,
            iaasType :  record.iaasType,
            accountId : record.accountId,
            iaasConfigAlias : record.iaasConfigAlias
     }
     
     w2popup.lock(delete_lock_msg, true);
     $.ajax({
             type : "DELETE",
             url : "/info/iaasConfig/google/delete",
             contentType : "application/json",
             dataType: "json",
             async : true,
             data : JSON.stringify(configInfo),
             success : function(status) {
                 w2popup.unlock();
                 w2popup.close();    
                 initsetting();
                 doSearch(); 
             },
             error : function(request, status, error) {
                 w2popup.unlock();
                 var errorResult = JSON.parse(request.responseText);
                 w2alert(errorResult.message);
             }
         });
}
    
/********************************************************
 * 기능 : doSearch
 * 설명 : 조회기능
 *********************************************************/
function doSearch() {
    $("#updateConfigBtn").attr('disabled', true);
    $("#deleteConfigBtn").attr('disabled', true);
    w2ui['google_configGrid'].load("<c:url value='/info/iaasConfig/google/list'/>","",function(event){});  
}


/********************************************************
 * 기능 : initsetting
 * 설명 : 기본 설정값 초기화
 *********************************************************/
function initsetting(){
  configInfo="";
  keyPathFileList = "";
}

/********************************************************
 * 기능 : clearMainPage
 * 설명 : 다른페이지 이동시 호출
 *********************************************************/
function clearMainPage() {
    $().w2destroy('google_configGrid');
}

/********************************************************
 * 기능 : resize
 * 설명 : 화면 리사이즈시 호출
 *********************************************************/
$( window ).resize(function() {
  setLayoutContainerHeight();
});


</script>
<div id="main">
    <div class="page_site">정보조회 > 인프라 환경 설정 관리 > <strong>Google 환경 설정 관리 </strong></div>
     <div class="pdt20">
        <div class="fl" style="width:100%">
            <div class="dropdown" >
                <a href="#" class="dropdown-toggle iaas-dropdown" data-toggle="dropdown" aria-expanded="false">
                    <i class="fa fa-cloud"></i>&nbsp;Google<b class="caret"></b>
                </a>
                <ul class="dropdown-menu alert-dropdown">
                    <sec:authorize access="hasAuthority('INFO_IAASCONFIG_AWS_LIST')">
                        <li><a href="javascript:goPage('<c:url value="/info/iaasConfig/aws"/>', 'AWS 관리');">AWS</a></li>
                    </sec:authorize>
                    <sec:authorize access="hasAuthority('INFO_IAASCONFIG_OPENSTACK_LIST')">
                        <li><a href="javascript:goPage('<c:url value="/info/iaasConfig/openstack"/>', 'Openstack 관리');">Openstack</a></li>
                    </sec:authorize>
                    <sec:authorize access="hasAuthority('INFO_IAASCONFIG_VSPHERE_LIST')">
                        <li><a href="javascript:goPage('<c:url value="/info/iaasConfig/vSphere"/>', 'vSphere 관리');">vSphere</a></li>
                    </sec:authorize>
                    <sec:authorize access="hasAuthority('INFO_IAASCONFIG_AZURE_LIST')">
                        <li><a href="javascript:goPage('<c:url value="/info/iaasConfig/azure"/>', 'vSphere 관리');">Azure</a></li>
                    </sec:authorize>
                    
                </ul>
            </div>
        </div> 
    </div>
    <div class="pdt20">
        <div class="title fl">Google 환경 설정 목록</div>
        <div class="fr"> 
            <!-- Button -->
            <sec:authorize access="hasAuthority('INFO_IAASCONFIG_GOOGLE_CREATE')">
               <span id="registConfigBtn" class="btn btn-primary" style="width:100px" >등록</span>
            </sec:authorize>
             <sec:authorize access="hasAuthority('INFO_IAASCONFIG_GOOGLE_UPDATE')">
               <span id="updateConfigBtn" class="btn btn-info" style="width:100px" >수정</span>
            </sec:authorize>
            <sec:authorize access="hasAuthority('INFO_IAASCONFIG_GOOGLE_DELETE')">
               <span id="deleteConfigBtn" class="btn btn-danger" style="width:100px" >삭제</span>
            </sec:authorize>
            <!-- //Btn -->
        </div>
        <div id="google_configGrid" style="width: 100%; height: 610px;"></div>
   </div>      
</div>

<!-- GOOGLE 등록 및 수정 팝업 Div-->
<div id="registPopupDiv" hidden="true">
    <input type="hidden" name="id" />   
    <form id="googleConfigForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
        <div class="panel panel-info"> 
            <div class="panel-heading"><b>Google 환경 설정 정보</b></div>
            <div class="panel-body" style="padding:20px 10px; height:340px; overflow-y:auto;">
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Google 환경 설정 별칭</label>
                    <div>
                        <input name="iaasConfigAlias" type="text"  maxlength="100" style="width: 300px" placeholder="환경 설정 별칭을 입력하세요."/>
                    </div>
                </div>
                 <div class="w2ui-field">
                    <label style="width:35%;text-align: left; padding-left: 20px;">Google 계정 별칭</label>
                    <div class="accountNameDiv"></div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Zone</label>
                    <div>
                        <select class='form-control select-control' name="commonAvailabilityZone" style="width:300px;">
                            <option value="">zone을 선택하세요.</option>
                        </select>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Network Tag Names</label>
                    <div>
                        <input name="googleTagNames" type="text"  maxlength="100" style="width: 300px" placeholder="ex)bosh-security, cf-security"/>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%; text-align: left; padding-left: 20px;">Public Key</label>
                    <div>
                        <input name="googlePublicKey" type="text" style="width: 300px; height: 60px;" placeholder="ex)ssh-rsa AEV...."/>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="width:36%;text-align: left; padding-left: 20px;">Private Key File</label>
                    <div>
                        <span onclick="changeKeyPathType('file');" style="width:30%;"><label><input type="radio" name="keyPathType" value="file" />&nbsp;파일업로드</label></span>
                        &nbsp;&nbsp;
                        <span onclick="changeKeyPathType('list');" style="width:30%;"><label><input type="radio" name="keyPathType" value="list" />&nbsp;목록에서 선택</label></span>
                    </div>
                </div>
                <div class="w2ui-field">
                    <label style="text-align: left;font-size:11px;" class="control-label"></label>
                    <div id="keyPathDiv" style="position:relative; width: 65%; left:220px;">
                        <div id="keyPathFileDiv" hidden="true">
                         <input type="text" id="keyPathFileName" name="keyPathFileName" style="width:55%;" readonly  onClick="openBrowse();" placeholder="업로드할 Key 파일을 선택하세요."/>
                         <a href="#" id="browse" onClick="openBrowse();"><span id="BrowseBtn">Browse</span></a>
                         <input type="file" name="keyPathFile" onchange="setPrivateKeyPathFileName(this);" style="display:none;"/>
                     </div>
                     <div id="keyPathListDiv">
                         <select name="keyPathList"  id="commonKeypairPathList" onchange="setPrivateKeyPath(this.value);" class="form-control select-control" style="width:55%"></select>
                     </div>
                    </div>
                    <input name="commonKeypairPath" type="hidden"/>
                </div>
            </div>
        </div>
    </form> 
</div>
<div id="registPopupBtnDiv" hidden="true">
     <button class="btn" id="registBtn" onclick="$('#googleConfigForm').submit();">확인</button>
     <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>
<div id="updatePopupBtnDiv" hidden="true">
    <button class="btn" id="updateBtn" onclick="$('#googleConfigForm').submit();">확인</button>
    <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

<script>
$(function() {
  $.validator.addMethod("sqlInjection", function(value, element, params) {
        return checkInjectionBlacklist(params);
      },text_injection_msg);
  
    $("#googleConfigForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
          iaasConfigAlias : {
            required : function(){
              return checkEmpty( $(".w2ui-msg-body input[name='iaasConfigAlias']").val() );
                }, sqlInjection : function(){
                  return $(".w2ui-msg-body input[name='iaasConfigAlias']").val();
                }
            }, googleTagNames: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='googleTagNames']").val() );
                }, sqlInjection :   function(){
                    return $(".w2ui-msg-body input[name='googleTagNames']").val();
                }
            }, googlePublicKey: {
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='googlePublicKey']").val());
                }, sqlInjection : function(){
                    return $(".w2ui-msg-body input[name='googlePublicKey']").val();
                }
            }, commonAvailabilityZone: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='commonAvailabilityZone']").val() );
                }
            }, keyPathList: { 
                required: function(){
                    if( $(".w2ui-msg-body input:radio[name='keyPathType']:checked").val() == 'list' ){
                        return checkEmpty(  $(".w2ui-msg-body select[name='keyPathList']").val() );
                    }else{
                         return false;
                    }
                }
            }, keyPathFileName: { 
                required: function(){
                    if( $(".w2ui-msg-body input:radio[name='keyPathType']:checked").val() == 'file' ){
                        return checkEmpty(  $(".w2ui-msg-body input[name='keyPathFileName']").val() );
                    }else{
                         return false;
                    }
                }
            }
        }, messages: {
            iaasConfigAlias: { 
                 required:  "Google 환경 설정 별칭" + text_required_msg
                , sqlInjection : text_injection_msg
            }, accountName: { 
                required:  "Google 인프라 계정 별칭"+text_required_msg
            }, googleTagNames: {
                required:  "태그 명"+text_required_msg
                ,sqlInjection : text_injection_msg
            }, googlePublicKey: {
                required:  "Public 키" + text_required_msg
                , sqlInjection : text_injection_msg
            }, commonAvailabilityZone: {
                required:  "영역"+select_required_msg
            }, keyPathList: { 
                required:  "Private 키 파일"+ select_required_msg
            }, keyPathFileName: { 
                required:  "Private 키 파일"+ text_required_msg
            }
        }, unhighlight: function(element) {
            setSuccessStyle(element);
        },errorPlacement: function(error, element) {
            //do nothing
        }, invalidHandler: function(event, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                setInvalidHandlerStyle(errors, validator);
            }
        }, submitHandler: function (form) {
          if(  $(".w2ui-msg-body input:radio[name='keyPathType']:checked").val() == 'file' ){
              uploadPrivateKey();
          }else{
              saveGoogleConfigInfo();
          }
        }
    });
});
</script>
