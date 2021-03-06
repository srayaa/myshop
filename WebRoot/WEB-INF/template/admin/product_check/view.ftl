<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>查看商品 - Powered By SHOP++</title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="${base}/resources/admin/css/common.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${base}/resources/admin/js/jquery.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/jquery.tools.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/jquery.validate.js"></script>
<script type="text/javascript" charset="utf-8" src="${base}/resources/admin/editor/kindeditor.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/common.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/input.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/upfile.js"></script>
<style type="text/css">
	.specificationSelect {
		height: 100px;
		padding: 5px;
		overflow-y: scroll;
		border: 1px solid #cccccc;
	}
	
	.specificationSelect li {
		float: left;
		min-width: 150px;
		_width: 200px;
	}
</style>
<script type="text/javascript">
$().ready(function() {

	var $inputForm = $("#inputForm");
	var $productCategoryId = $("#productCategoryId");
	var $all_checked = $("#all_checked");
	var $all_not_checked = $("#all_not_checked");
	var $all_checked_button = $("#all_checked_button");
	var $all_not_checked_button = $("#all_not_checked_button");
	var $isMemberPrice = $("#isMemberPrice");
	var $memberPriceTr = $("#memberPriceTr");
	var $memberPrice = $("#memberPriceTr input");
	var $browserButton = $("#browserButton");
	var $browserButton1 = $("#browserButton1"); 
	var $browserButton2 = $("#browserButton2"); 
	var $productImageTable = $("#productImageTable");
	var $addProductImage = $("#addProductImage");
	var $deleteProductImage = $("a.deleteProductImage");
	var $parameterTable = $("#parameterTable");
	var $attributeTable = $("#attributeTable");
	var $specificationIds = $("#specificationSelect :checkbox");
	var $specificationProductTable = $("#specificationProductTable");
	var $addSpecificationProduct = $("#addSpecificationProduct");
	var $deleteSpecificationProduct = $("a.deleteSpecificationProduct");
	var productImageIndex = ${(product.productImages?size)!"0"};
	var previousProductCategoryId = "${product.productCategory.id}";
	
	[@flash_message /]
	
	$browserButton.browser();
	$browserButton1.upfile();
	$browserButton2.browser();
	
	// 会员价
	$isMemberPrice.click(function() {
		if ($(this).prop("checked")) {
			$memberPriceTr.show();
			$memberPrice.prop("disabled", false);
		} else {
			$memberPriceTr.hide();
			$memberPrice.prop("disabled", true);
		}
	});
	
	
	// 增加商品图片
	$addProductImage.click(function() {
		[@compress single_line = true]
			var trHtml = 
			'<tr>
				<td>
					<input type="file" name="productImages[' + productImageIndex + '].file" class="productImageFile" \/>
				<\/td>
				<td>
					<input type="text" name="productImages[' + productImageIndex + '].title" class="text" maxlength="200" \/>
				<\/td>
				<td>
					<input type="text" name="productImages[' + productImageIndex + '].order" class="text productImageOrder" maxlength="9" style="width: 50px;" \/>
				<\/td>
				<td>
					<a href="javascript:;" class="deleteProductImage">[${message("admin.common.delete")}]<\/a>
				<\/td>
			<\/tr>';
		[/@compress]
		$productImageTable.append(trHtml);
		productImageIndex ++;
	});
	
	// 删除商品图片
	$deleteProductImage.live("click", function() {
		var $this = $(this);
		$.dialog({
			type: "warn",
			content: "${message("admin.dialog.deleteConfirm")}",
			onOk: function() {
				$this.closest("tr").remove();
			}
		});
	});
	
	// 修改商品分类
	$productCategoryId.change(function() {
		var hasValue = false;
		$parameterTable.add($attributeTable).find(":input").each(function() {
			if ($.trim($(this).val()) != "") {
				hasValue = true;
				return false;
			}
		});
		if (hasValue) {
			$.dialog({
				type: "warn",
				content: "${message("admin.product.productCategoryChangeConfirm")}",
				width: 450,
				onOk: function() {
					loadParameter();
					loadAttribute();
					previousProductCategoryId = $productCategoryId.val();
				},
				onCancel: function() {
					$productCategoryId.val(previousProductCategoryId);
				}
			});
		} else {
			loadParameter();
			loadAttribute();
			previousProductCategoryId = $productCategoryId.val();
		}
	});
	
	// 加载参数
	function loadParameter() {
		$.ajax({
			url: "parameter_groups.jhtml",
			type: "GET",
			data: {id: $productCategoryId.val()},
			dataType: "json",
			beforeSend: function() {
				$parameterTable.empty();
			},
			success: function(data) {
				var trHtml = "";
				$.each(data, function(i, parameterGroup) {
					trHtml += '<tr><td style="text-align: right;"><strong>' + parameterGroup.name + ':<\/strong><\/td><td>&nbsp;<\/td><\/tr>';
					$.each(parameterGroup.parameters, function(i, parameter) {
						[@compress single_line = true]
							trHtml += 
							'<tr>
								<th>' + parameter.name + ': <\/th>
								<td>
									<input type="text" name="parameter_' + parameter.id + '" class="text" maxlength="200" \/>
								<\/td>
							<\/tr>';
						[/@compress]
					});
				});
				$parameterTable.append(trHtml);
			}
		});
	}
	
	// 加载属性
	function loadAttribute() {
		$.ajax({
			url: "attributes.jhtml",
			type: "GET",
			data: {id: $productCategoryId.val()},
			dataType: "json",
			beforeSend: function() {
				$attributeTable.empty();
			},
			success: function(data) {
				var trHtml = "";
				$.each(data, function(i, attribute) {
					var optionHtml = '<option value="">${message("admin.common.choose")}<\/option>';
					$.each(attribute.options, function(j, option) {
						optionHtml += '<option value="' + option + '">' + option + '<\/option>';
					});
					[@compress single_line = true]
						trHtml += 
						'<tr>
							<th>' + attribute.name + ': <\/th>
							<td>
								<select name="attribute_' + attribute.id + '">
									' + optionHtml + '
								<\/select>
							<\/td>
						<\/tr>';
					[/@compress]
				});
				$attributeTable.append(trHtml);
			}
		});
	}
	
	// 修改商品规格
	$specificationIds.click(function() {
		if ($specificationIds.filter(":checked").size() == 0) {
			$specificationProductTable.find("tr:gt(1)").remove();
		}
		var $this = $(this);
		if ($this.prop("checked")) {
			$specificationProductTable.find("td.specification_" + $this.val()).show().find("select").prop("disabled", false);
		} else {
			$specificationProductTable.find("td.specification_" + $this.val()).hide().find("select").prop("disabled", true);
		}
	});
	
	// 增加规格商品
	$addSpecificationProduct.click(function() {
		if ($specificationIds.filter(":checked").size() == 0) {
			$.message("warn", "${message("admin.product.specificationRequired")}");
			return false;
		}
		if ($specificationProductTable.find("tr:gt(1)").size() == 0) {
			$tr = $specificationProductTable.find("tr:eq(1)").clone().show().appendTo($specificationProductTable);
			$tr.find("td:first").text("${message("admin.product.currentSpecification")}");
			$tr.find("td:last").text("-");
		} else {
			$specificationProductTable.find("tr:eq(1)").clone().show().appendTo($specificationProductTable);
		}
	});
	
	// 删除规格商品
	$deleteSpecificationProduct.live("click", function() {
		var $this = $(this);
		$.dialog({
			type: "warn",
			content: "${message("admin.dialog.deleteConfirm")}",
			onOk: function() {
				$this.closest("tr").remove();
			}
		});
	});
	
	$.validator.addClassRules({
		memberPrice: {
			min: 0,
			decimal: {
				integer: 12,
				fraction: ${setting.priceScale}
			}
		},
		productImageFile: {
			required: true,
			extension: "${setting.uploadImageExtension}"
		},
		productImageOrder: {
			digits: true
		}
	});
	
	// 表单验证
	$inputForm.validate({
		rules: {
			productCategoryId: "required",
			name: "required",
			sn: {
				pattern: /^[0-9a-zA-Z_-]+$/,
				remote: {
					url: "check_sn.jhtml?previousSn=${product.sn}",
					cache: false
				}
			},
			price: {
				required: true,
				min: 0,
				decimal: {
					integer: 12,
					fraction: ${setting.priceScale}
				}
			},
			cost: {
				min: 0,
				decimal: {
					integer: 12,
					fraction: ${setting.priceScale}
				}
			},
			marketPrice: {
				min: 0,
				decimal: {
					integer: 12,
					fraction: ${setting.priceScale}
				}
			},
			weight: "digits",
			stock: "digits",
			point: "digits"
		},
		messages: {
			sn: {
				pattern: "${message("admin.validate.illegal")}",
				remote: "${message("admin.validate.exist")}"
			}
		},
		submitHandler: function(form) {
			if ($specificationIds.filter(":checked").size() > 0 && $specificationProductTable.find("tr:gt(1)").size() == 0) {
				$.message("warn", "${message("admin.product.specificationProductRequired")}");
				return false;
			} else {
				var isRepeats = false;
				var parameters = new Array();
				$specificationProductTable.find("tr:gt(1)").each(function() {
					var parameter = $(this).find("select").serialize();
					if ($.inArray(parameter, parameters) >= 0) {
						$.message("warn", "${message("admin.product.specificationValueRepeat")}");
						isRepeats = true;
						return false;
					} else {
						parameters.push(parameter);
					}
				});
				if (!isRepeats) {
					$specificationProductTable.find("tr:eq(1)").find("select").prop("disabled", true);
					addCookie("previousProductCategoryId", $productCategoryId.val(), {expires: 24 * 60 * 60});
					form.submit();
				}
			}
		}
	});
	
});
</script>
</head>
<body>
	<div class="path">
		<a href="${base}/admin/common/index.jhtml">${message("admin.path.index")}</a> &raquo; 查看商品
	</div>
		<input type="hidden" name="id" value="${product.id}" />
		<ul id="tab" class="tab">
			<li>
				<input type="button" value="${message("admin.product.base")}" />
			</li>
			<li>
				<input type="button" value="${message("admin.product.introduction")}" />
			</li>
			<li>
				<input type="button" value="${message("admin.product.productImage")}" />
			</li>
			<li>
				<input type="button" value="${message("admin.product.parameter")}" />
			</li>
			<li>
				<input type="button" value="${message("admin.product.attribute")}" />
			</li>
			<li>
				<input type="button" value="${message("admin.product.specification")}" />
			</li>
		</ul>
		<table class="input tabContent">
			[#if product.specifications?has_content]
				<tr>
					<th>
						${message("Product.specifications")}:
					</th>
					<td>
						[#list product.specificationValues as specificationValue]
							${specificationValue.name}
						[/#list]
					</td>
				</tr>
			[/#if]
			[#if product.validPromotions?has_content]
				<tr>
					<th>
						${message("Product.promotions")}:
					</th>
					<td>
						[#list product.validPromotions as promotion]
							<p>
								${promotion.name}
								[#if promotion.beginDate?? || promotion.endDate??]
									[${promotion.beginDate} ~ ${promotion.endDate}]
								[/#if]
							</p>
						[/#list]
					</td>
				</tr>
			[/#if]
			<tr>
				<th>
					${message("Product.productCategory")}:
				</th>
				<td>
					<select disabled id="productCategoryId" name="productCategoryId">
						<option>${product.productCategory.name}<option>
					</select>
				</td>
			</tr>
			<tr>
				<th>
					<span class="requiredField">*</span>${message("Product.name")}:
				</th>
				<td>
					<input disabled type="text" name="name" class="text" value="${product.name}" maxlength="200" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.sn")}:
				</th>
				<td>
					<input disabled type="text" name="sn" class="text" value="${product.sn}" maxlength="100" title="${message("admin.product.snTitle")}" />
				</td>
			</tr>
			
			<tr>
				<th>
					<span class="requiredField">*</span>${message("Product.price")}:
				</th>
				<td>
					<input disabled type="text" name="price" class="text" value="${product.price}" maxlength="16" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.memberPrice")}:
				</th>
				<td>
					<label>
						<input disabled type="checkbox" id="isMemberPrice" name="isMemberPrice" value="true"[#if product.memberPrice?has_content] checked="checked"[/#if] />${message("admin.product.isMemberPrice")}
					</label>
				</td>
			</tr>
			
			<tr id="memberPriceTr"[#if !product.memberPrice?has_content] class="hidden"[/#if]>
				<th>
					&nbsp;
				</th>
				<td>
					[#list memberRanks as memberRank]
						${memberRank.name}: <input type="text" name="memberPrice_${memberRank.id}" class="text memberPrice" value="${product.memberPrice.get(memberRank)}" maxlength="16" style="width: 60px; margin-right: 6px;"[#if !product.memberPrice?has_content] disabled="disabled"[/#if] />
					[/#list]
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.cost")}:
				</th>
				<td>
					<input disabled type="text" name="cost" class="text" value="${product.cost}" maxlength="16" title="${message("admin.product.costTitle")}" />
				</td>
			</tr>
			<tr>
				<th>
					${message("Product.marketPrice")}:
				</th>
				<td>
					<input disabled type="text" name="marketPrice" class="text" value="${product.marketPrice}" maxlength="16" title="${message("admin.product.marketPriceTitle")}" />
				</td>
			</tr>
			<tr>
				<th>
					${message("Product.image")}:
				</th>
				<td>
					<span class="fieldSet">
						<input disabled type="text" name="image" class="text" value="${product.image}" maxlength="200" title="${message("admin.product.imageTitle")}" />
						[#if product.image??]
							<a href="${product.image}" target="_blank">${message("admin.common.view")}</a>
						[/#if]
					</span>
				</td>
			</tr>
			
			</tr>
			<tr>
				<th>
					${message("Product.unit")}:
				</th>
				<td>
					<input disabled type="text" name="unit" class="text" maxlength="200" value="${product.unit}" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.weight")}:
				</th>
				<td>
					<input disabled type="text" name="weight" class="text" value="${product.weight}" maxlength="9" title="${message("admin.product.weightTitle")}" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.stock")}:
				</th>
				<td>
					<input disabled type="text" name="stock" class="text" value="${product.stock}" maxlength="9" title="${message("admin.product.stockTitle")}" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.stockMemo")}:
				</th>
				<td>
					<input disabled type="text" name="stockMemo" class="text" value="${product.stockMemo}" maxlength="200" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.point")}:
				</th>
				<td>
					<input disabled type="text" name="point" class="text" value="${product.point}" maxlength="9" title="${message("admin.product.pointTitle")}" />
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.brand")}:
				</th>
				<td>
					${product.brand.name}
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.tags")}:
				</th>
				<td>
					[#list tags as tag]
						<label>
							<input disabled type="checkbox" name="tagIds" value="${tag.id}"[#if product.tags?seq_contains(tag)] checked="checked"[/#if] />${tag.name}
						</label>
					[/#list]
				</td>
			</tr>
			
			<tr>
				<th>
					${message("admin.common.setting")}:
				</th>
				<td>
					<label>
						<input disabled type="checkbox" name="isList" value="true"[#if product.isList] checked="checked"[/#if] />${message("Product.isList")}
					</label>
					<label>
						<input disabled type="checkbox" name="isTop" value="true"[#if product.isTop] checked="checked"[/#if] />${message("Product.isTop")}
					</label>
					<label>
						<input disabled type="checkbox" name="isGift" value="true"[#if product.isGift] checked="checked"[/#if] />${message("Product.isGift")}
					</label>
				</td>
			</tr>
			
			<tr>
				<th>
					${message("Product.memo")}:
				</th>
				<td>
					<input disabled type="text" name="memo" class="text" value="${product.memo}" maxlength="200" />
				</td>
			</tr>
			<tr>
				<th>
					${message("Product.keyword")}:
				</th>
				<td>
					<input disabled type="text" name="keyword" class="text" value="${product.keyword}" maxlength="200" title="${message("admin.product.keywordTitle")}" />
				</td>
			</tr>
			<tr>
				<th>
					${message("Product.seoTitle")}:
				</th>
				<td>
					<input disabled type="text" name="seoTitle" class="text" value="${product.seoTitle}" maxlength="200" />
				</td>
			</tr>
			<tr>
				<th>
					${message("Product.seoKeywords")}:
				</th>
				<td>
					<input disabled type="text" name="seoKeywords" class="text" value="${product.seoKeywords}" maxlength="200" />
				</td>
			</tr>
			<tr>
				<th>
					${message("Product.seoDescription")}:
				</th>
				<td>
					<input disabled type="text" name="seoDescription" class="text" value="${product.seoDescription}" maxlength="200" />
				</td>
			</tr>
            <tr>
            	<th>所属店铺:</th>
                <td>${product.store.name}</td>    
            </tr>
		</table>
		<table class="input tabContent">
			<tr>
				<td>
					<textarea id="editor" name="introduction" class="editor" style="width: 100%;">${product.introduction?html}</textarea>
					<br>产品特征<br>
					<textarea id="editor2" name="features" class="editor" style="width: 100%;">${product.features?html}</textarea>
					<br>产品外观<br>
					<textarea id="editor5" name="showimg" class="editor" style="width: 100%;">${product.showimg?html}</textarea>
					<br>核心部件<br>
					<textarea id="editor3" name="core" class="editor" style="width: 100%;">${product.core?html}</textarea>
					<br>用户体验<br>
					<textarea id="editor4" name="ue" class="editor" style="width: 100%;">${product.ue?html}</textarea>
				</td>
			</tr>
		</table>
		
		<table id="productImageTable" class="input tabContent">
			<tr class="title">
				<th>
					${message("ProductImage.file")}
				</th>
				<th>
					${message("ProductImage.title")}
				</th>
				<th>
					${message("admin.common.order")}
				</th>
				<th>
					${message("admin.common.delete")}
				</th>
			</tr>
			[#list product.productImages as productImage]
				<tr>
					<td>
						<a href="${productImage.large}" target="_blank">${message("admin.common.view")}</a>
					</td>
					<td>
						<input disabled type="text" name="productImages[${productImage_index}].title" class="text" maxlength="200" value="${productImage.title}" />
					</td>
					<td>
						<input disabled type="text" name="productImages[${productImage_index}].order" class="text productImageOrder" value="${productImage.order}" maxlength="9" style="width: 50px;" />
					</td>
				</tr>
			[/#list]
		</table>
		<table id="parameterTable" class="input tabContent">
			[#list parameterGroups as parameterGroup]
				<tr>
					<td style="text-align: right; padding-right: 10px;">
						<strong>${parameterGroup.name}:</strong>
					</td>
					<td>
						&nbsp;
					</td>
				</tr>
				[#list parameterGroup.parameters as parameter]
					<tr>
						<th>${parameter.name}:</th>
						<td>
							<input disabled type="text" name="parameter_${parameter.id}" class="text" value="${product.parameterValue.get(parameter)}" maxlength="200" />
						</td>
					</tr>
				[/#list]
			[/#list]
		</table>
		<table id="attributeTable" class="input tabContent">
			[#list attributes as attribute]
				<tr>
					<th>${attribute.name}:</th>
					<td>
						<select name="attribute_${attribute.id}"  disabled>
							<option value="">${message("admin.common.choose")}</option>
							[#list attribute.options as option]
								${product.getAttributeValue(attribute)}<option value="${option}"[#if option == product.getAttributeValue(attribute)] selected="selected"[/#if]>${option}</option>
							[/#list]
						</select>
					</td>
				</tr>
			[/#list]
		</table>
		<table class="input tabContent">
			<tr class="title">
				<th>
					${message("admin.product.selectSpecification")}:
				</th>
			</tr>
			<tr>
				<td>
					<div id="specificationSelect" class="specificationSelect">
						<ul>
							[#list specifications as specification]
								<li>
									<label>
										<input disabled type="checkbox" name="specificationIds" value="${specification.id}"[#if product.specifications?seq_contains(specification)] checked="checked"[/#if] />${specification.name}
										[#if specification.memo??]
											<span class="gray">[${specification.memo}]</span>
										[/#if]
									</label>
								</li>
							[/#list]
						</ul>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<table id="specificationProductTable" class="input">
						<tr class="title">
							<td width="60">
								&nbsp;
							</td>
							[#list specifications as specification]
								<td class="specification_${specification.id}[#if !product.specifications?seq_contains(specification)] hidden[/#if]">
									${specification.name}
									[#if specification.memo??]
										<span class="gray">[${specification.memo}]</span>
									[/#if]
								</td>
							[/#list]
						</tr>
						<tr class="hidden">
							<td>
								&nbsp;
							</td>
							[#list specifications as specification]
								<td class="specification_${specification.id}[#if !product.specifications?seq_contains(specification)] hidden[/#if]">
									<select disabled name="specification_${specification.id}"[#if !product.specifications?seq_contains(specification)] disabled="disabled"[/#if]>
										[#list specification.specificationValues as specificationValue]
											<option value="${specificationValue.id}">${specificationValue.name}</option>
										[/#list]
									</select>
								</td>
							[/#list]
						</tr>
						[#if product.specifications?has_content]
							<tr>
								<td>
									${message("admin.product.currentSpecification")}
								</td>
								[#list specifications as specification]
									<td class="specification_${specification.id}[#if !product.specifications?seq_contains(specification)] hidden[/#if]">
										<select disabled name="specification_${specification.id}"[#if !product.specifications?seq_contains(specification)] disabled="disabled"[/#if]>
											[#list specification.specificationValues as specificationValue]
												<option value="${specificationValue.id}"[#if product.specificationValues?seq_contains(specificationValue)] selected="selected"[/#if]>${specificationValue.name}</option>
											[/#list]
										</select>
									</td>
								[/#list]
								<td>
									-
								</td>
							</tr>
						[/#if]
						[#list product.siblings as specificationProduct]
							<tr>
								<td>
									&nbsp;
								</td>
								[#list specifications as specification]
									<td class="specification_${specification.id}[#if !specificationProduct.specifications?seq_contains(specification)] hidden[/#if]">
										<select disabled name="specification_${specification.id}"[#if !specificationProduct.specifications?seq_contains(specification)] disabled="disabled"[/#if]>
											[#list specification.specificationValues as specificationValue]
												<option value="${specificationValue.id}"[#if specificationProduct.specificationValues?seq_contains(specificationValue)] selected="selected"[/#if]>${specificationValue.name}</option>
											[/#list]
										</select>
									</td>
								[/#list]
							</tr>
						[/#list]
					</table>
				</td>
			</tr>
		</table>
		<table class="input">
			<tr>
				<th>
					&nbsp;
				</th>
				<td>
                    <input disabled type="button" class="button" disabled value="${message("admin.common.submit")}" />
					<input type="button" class="button" value="${message("admin.common.back")}" onclick="location.href='list.jhtml'" />
				</td>
			</tr>
		</table>
</body>
</html>