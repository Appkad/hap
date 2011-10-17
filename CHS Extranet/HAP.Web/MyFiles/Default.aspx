﻿<%@ Page Title="" Language="C#" MasterPageFile="~/masterpage.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HAP.Web.MyFiles.Default" %>
<asp:Content ContentPlaceHolderID="head" runat="server">
	<script src="../Scripts/jquery-1.6.2.min.js" type="text/javascript"></script>
	<script src="../Scripts/jquery-ui-1.8.16.custom.min.js" type="text/javascript"></script>
	<script src="../Scripts/jquery.ba-hashchange.min.js" type="text/javascript"></script>
	<script src="../Scripts/jquery.dynatree.js" type="text/javascript"></script>
	<link href="../style/ui.dynatree.css" rel="stylesheet" type="text/css" />
	<link href="../style/MyFiles.css" rel="stylesheet" type="text/css" />
</asp:Content>
<asp:Content ContentPlaceHolderID="body" runat="server">
		<div style="overflow: hidden; clear: both; position: relative;">
		<div class="tiles" style="position: absolute; left: 0; margin-top: 45px;">
			<a class="button" href="../">Home Access Plus+ Home</a>
		</div>
		<div class="tiles" style="float: right; text-align: right; margin-top: 45px;">
		</div>
		<div style="text-align: center;">
			<img src="../images/myfiles.png" alt="My Files" />
		</div>
	</div>
	<div id="toolbar" style="padding: 4px; margin-bottom: 4px;" class="ui-widget-header">
		<button class="dropdown">Organise</button> <button>Open</button> <button>New Folder</button><button class="dropdown" style="float: right;">View</button>
	</div>
	<div id="Tree" class="tile-border-color">
	</div>
	<div id="MyFiles" class="tiles">
	</div>
	<script type="text/javascript">
		var items = new Array();
		var curpath = null;
		$(window).hashchange(function () {
			if (window.location.href.split('#')[1] != "" && window.location.href.split('#')[1]) curpath = window.location.href.split("#")[1];
			else curpath = null;
			Load();
		});
		function Drive(data) {
			this.Data = data;
			this.Id = "";
			this.Render = function () {
				this.Id = this.Data.Path.substr(0, 1);
				var label = this.Data.Name + " (" + this.Data.Path.substr(0, 1) + ")";

				$("#MyFiles").append('<a id="' + this.Id + '" href="#' + this.Data.Path + '" class="Drive"><span class="icon" style="background-image: url(' + this.Data.Icon + ');"></span><span class="label">' + label + '</span><span class="progress"><label>' + this.Data.Space + '%</label><i style="width: ' + this.Data.Space + '%"></i></span></a>');
				if ($("#Tree > ul > li > ul").has("#nav-" + this.Id).length == 0) 
					$("#Tree > ul > li > ul").append('<li id="nav-' + this.Id + '"><a href="#' + this.Data.Path + '">' + this.Data.Name + '</a></li>');
			};
			this.Refresh = function () {
				$("#" + this.Id).attr("href", "#" + this.Data.Path);
				var label = this.Data.Name + " (" + this.Data.Path + ")";
				$("#" + this.Id).html('<span class="icon" style="background-image: url(' + this.Data.Icon + ');"></span><span class="label">' + label + '</span><span class="progress"><label>' + this.Data.Space + '%</label><i style="width: ' + this.Data.Space + '%"></i></span>');
				$('#nav-' + this.Id + ' > a').attr("href", '#' + this.Data.Path);
				$('#nav-' + this.Id + ' > a').html(this.Data.Name);
			};
		}
		function Item(data) {
			this.Data = data;
			this.Id = "";
			this.Render = function () {
				this.Id = this.Data.Name.replace(/ /g, "_");
				var label = this.Data.Name;

				var h = '<a id="' + this.Id + '" ';
				if (this.Data.Type == 'Directory') h += 'class="Folder Selectable" ';
				else h += 'class="Selectable" ';
				h += 'href="' + (this.Data.Path.match(/\.\./i) ? this.Data.Path.replace(/\\/g, "/") : '#' + this.Data.Path) + '"><img class="icon" src="' + this.Data.Icon + '" alt="" /><span class="label">' + label + '</span><span class="type">';
				if (this.Data.Type == 'Directory') h += 'File Folder';
				else h += this.Data.Type + '<br />' + this.Data.Size;
				h += '</span></a>';
				$("#MyFiles").append(h);
				$("#" + this.Id).click(this.Click);
				$("#" + this.Id).click(function () { return false; });
			};
			this.Refresh = function () {
				$("#" + this.Id).attr("href", "#" + this.Data.Path);
				if (this.Selected) $("#" + this.Id).addClass("Selected");
				else $("#" + this.Id).removeClass("Selected");
				var label = this.Data.Name;
				var h = '<img class="icon" src="' + this.Data.Icon + '" alt="" /><span class="label">' + label + '</span><span class="type">';
				if (this.Data.Type == 'Directory') h += 'File Folder';
				else h += this.Data.Type + '<br />' + this.Data.Size;
				h += '</span>';

				$("#" + this.Id).html(h);
			};
			this.Selected = false;
			this.Click = function (e) {
				clearTimeout(ClickCapture.Timer);
				ClickCapture.Timer = setTimeout(function () { ClickCapture.Clicks = 0; }, ClickCapture.Delay);
				ClickCapture.Clicks++;
				if (ClickCapture.Clicks === 1) {
					var item = null;
					for (var x = 0; x < items.length; x++)
						if (items[x].Id == $(this).attr("id")) { item = items[x]; break; }
					item.Selected = !item.Selected;
					item.Refresh();
				} else {
					e.preventDefault();
					var item = null;
					for (var x = 0; x < items.length; x++)
						if (items[x].Id == $(this).attr("id")) { item = items[x]; break; }
					window.location.href = (item.Data.Path.match(/\.\./i) ? item.Data.Path.replace(/\\/g, "/") : '#' + item.Data.Path);
				}
			};
		}
		var ClickCapture = { Delay: 500, Clicks: 0, Timer: null };
		function Load() {
			if (curpath == null) {
				$.ajax({
					type: 'GET',
					url: '<%=ResolveUrl("~/api/MyFiles/Drives")%>',
					dataType: 'json',
					contentType: 'application/json; charset=utf-8',
					success: function (data) {
						items = new Array();
						$("#MyFiles").html("");
						for (var i = 0; i < data.length; i++)
							items.push(new Drive(data[i]));
						for (var i = 0; i < items.length; i++)
							items[i].Render();
		            }, error: OnError
				});
			} else {
				$.ajax({
					type: 'GET',
					url: '<%=ResolveUrl("~/api/MyFiles/")%>' + curpath.replace(/\\/gi, "/"),
					dataType: 'json',
					contentType: 'application/json; charset=utf-8',
					success: function (data) {
						items = new Array();
						$("#MyFiles").html("");
						for (var i = 0; i < data.length; i++)
							items.push(new Item(data[i]));
						for (var i = 0; i < items.length; i++)
							items[i].Render();
		            }, error: OnError
				});
			}
		}
		$(function () {
			$("#Tree").dynatree({ imagePath: "../images/setup/", selectMode: 1, noLink: false, minExpandLevel: 1, children: [{ title: "My Drives", href: "#", isFolder: true, isLazy: true}], fx: { height: "toggle", duration: 200 },
				onLazyRead: function (node) {
					if (node.data.href == "#") {
						$.ajax({
							type: 'GET',
							url: '<%=ResolveUrl("~/api/MyFiles/Drives")%>',
							dataType: 'json',
							contentType: 'application/json; charset=utf-8',
							success: function (data) {
								res = [];
								for (var i = 0; i < data.length; i++)
									res.push({ title: data[i].Name, href: "#" + data[i].Path, isFolder: true, isLazy: true, noLink: false, key: data[i].Path });
								node.setLazyNodeStatus(DTNodeStatus_Ok);
								node.addChild(res);
				            }, error: OnError
						});
					} else {
						$.ajax({
							type: 'GET',
							url: '<%=ResolveUrl("~/api/MyFiles/")%>' + node.data.href.substr(1).replace(/\\/g, "/"),
							dataType: 'json',
							contentType: 'application/json; charset=utf-8',
							success: function (data) {
								res = [];
								for (var i = 0; i < data.length; i++)
									if (data[i].Type == "Directory") {
										res.push({ title: data[i].Name, href: "#" + data[i].Path, isFolder: true, isLazy: true, noLink: false, key: data[i].Path });
									}
								node.setLazyNodeStatus(DTNodeStatus_Ok);
								node.addChild(res);
							}, error: OnError
						});
					}
				},
				onRender: function (dtnode, nodeSpan) {
					if (dtnode.data.href != "#")
						$(nodeSpan).children("a").attr("href", dtnode.data.href);
				}
			});
			function OnError(xhr, ajaxOptions, thrownError) {
				console.log(thrownError);
				console.log(ajaxOptions);
				console.log(xhr);
				alert(thrownError);
			}
			if (window.location.href.split('#')[1] != "" && window.location.href.split('#')[1]) curpath = window.location.href.split("#")[1];
			else curpath = null;
			Load();
			$("button").button();
			$("button").click(function () { return false; });
			$("button.dropdown").button({ icons: { secondary: "ui-icon-carat-1-s"} });
			$(".button").button();
		});
	</script>
</asp:Content>