{*<!-- {[The file is published on the basis of YetiForce Public License 3.0 that can be found in the following directory: licenses/LicenseEN.txt or yetiforce.com]} -->*}
{strip}
	{foreach key=BLOCK_LABEL_KEY item=FIELD_MODEL_LIST from=$RECORD_STRUCTURE}
		{assign var=BLOCK value=$BLOCK_LIST[$BLOCK_LABEL_KEY]}
	{if $BLOCK eq null or $FIELD_MODEL_LIST|@count lte 0}{continue}{/if}
	{assign var=BLOCKS_HIDE value=$BLOCK->isHideBlock($RECORD,$VIEW)}
	{assign var=IS_HIDDEN value=$BLOCK->isHidden()}
	{assign var=WIDTHTYPE value=$USER_MODEL->get('rowheight')}
	{if $BLOCKS_HIDE}

		<div class="detailViewTable">
			<div class="js-toggle-panel c-panel__content" data-js="click" data-label="{$BLOCK_LABEL}">					
				<div class="blockHeader c-panel__header">
					<span class="u-cursor-pointer js-block-toggle fas fa-angle-right m-2 {if !($IS_HIDDEN)}d-none{/if}" data-js="click" alt="{\App\Language::translate('LBL_EXPAND_BLOCK')}" data-mode="hide" data-id={$BLOCK_LIST[$BLOCK_LABEL_KEY]->get('id')}></span>
					<span class="u-cursor-pointer js-block-toggle fas fa-angle-down m-2 {if $IS_HIDDEN}d-none{/if}" data-js="click" alt="{\App\Language::translate('LBL_COLLAPSE_BLOCK')}" data-mode="show" data-id={$BLOCK_LIST[$BLOCK_LABEL_KEY]->get('id')}></span>
					<h4>{\App\Language::translate({$BLOCK_LABEL_KEY},{$MODULE_NAME})}</h4>
				</div>
				<div class="blockContent c-panel__body {if $IS_HIDDEN} d-none{/if}">
					{assign var=COUNTER value=0}
					<div class="form-row border-bottom u-border-bottom-0-sm">
						{foreach item=FIELD_MODEL key=FIELD_NAME from=$FIELD_MODEL_LIST}
							{if !$FIELD_MODEL->isViewableInDetailView()}
								{continue}
							{/if}
							{if $FIELD_MODEL->getUIType() eq '300'}
								<div class="col-12 knowledgeBaseDetails">
									<span class="value" data-field-type="{$FIELD_MODEL->getFieldDataType()}" {if $FIELD_MODEL->getUIType() eq '19' or $FIELD_MODEL->getUIType() eq '20' or $FIELD_MODEL->getUIType() eq '21' or $FIELD_MODEL->getUIType() eq '300'} style="white-space:normal;" {/if}>
										{include file=\App\Layout::getTemplatePath($FIELD_MODEL->getUITypeModel()->getDetailViewTemplateName(),  $MODULE_NAME) FIELD_MODEL=$FIELD_MODEL USER_MODEL=$USER_MODEL MODULE=$MODULE_NAME RECORD=$RECORD}
									</span>
								</div>
							{else if $FIELD_MODEL->getUIType() eq "69" || $FIELD_MODEL->getUIType() eq "105"}
								{if $COUNTER neq 0}
									{if $COUNTER eq 2}
									</div><div class="form-row">
										{assign var=COUNTER value=0}
									{/if}
								{/if}
								<div class="col-md-6 form-row pl-1">
									<div class="fieldLabel col-sm-6 {$WIDTHTYPE}">
										<label class="u-text-small-bold">{\App\Language::translate({$FIELD_MODEL->getFieldLabel()},{$MODULE_NAME})}</label>
									</div>
									<div class="fieldValue col-sm-6 {$WIDTHTYPE}">
										<div id="imageContainer">
											{foreach key=ITER item=IMAGE_INFO from=$IMAGE_DETAILS}
												{if !empty($IMAGE_INFO.path) && !empty({$IMAGE_INFO.orgname})}
													<img src="data:image/jpg;base64,{base64_encode(file_get_contents($IMAGE_INFO.path))}" width="300" height="200">
												{/if}
											{/foreach}
										</div>
									</div>
								</div>
								{assign var=COUNTER value=$COUNTER+1}
							{else}
								{if $FIELD_MODEL->getUIType() eq "20" or $FIELD_MODEL->getUIType() eq "19" or $FIELD_MODEL->getUIType() eq '300'}
									{if $COUNTER eq '1'}
										{assign var=COUNTER value=0}
									{/if}
								{/if}
								{if $COUNTER eq 2}
								</div><div class="form-row border-bottom u-border-bottom-0-sm">
									{assign var=COUNTER value=1}
								{else}
									{assign var=COUNTER value=$COUNTER+1}
								{/if}
								<div class="col-sm-6">
									<div class="form-row border-right">
										<div class="fieldLabel u-border-bottom-label-md u-border-right-0-md c-panel_label col-lg-6 {$WIDTHTYPE} text-right" id="{$MODULE_NAME}_detailView_fieldLabel_{$FIELD_MODEL->getName()}">
											{assign var=HELPINFO value=explode(',',$FIELD_MODEL->get('helpinfo'))}
											{assign var=HELPINFO_LABEL value=$MODULE_NAME|cat:'|'|cat:$FIELD_MODEL->getFieldLabel()}
											{if in_array($VIEW,$HELPINFO) && \App\Language::translate($HELPINFO_LABEL, 'HelpInfo') neq $HELPINFO_LABEL}
												<a style="margin-left: 5px;margin-top: 2px;" href="#" class="js-help-info float-right" title="" data-placement="top" data-content="{\App\Language::translate($HELPINFO_LABEL, 'HelpInfo')}" data-original-title='{\App\Language::translate($FIELD_MODEL->getFieldLabel(), $MODULE_NAME)}'><i class="fas fa-info-circle"></i></a>
												{/if}
											<label class="u-text-small-bold">
												{\App\Language::translate({$FIELD_MODEL->getFieldLabel()},{$MODULE_NAME})}
											</label>
										</div>
										<div class="fieldValue u-border-bottom-value-sm col-sm-12 {$WIDTHTYPE} {if $FIELD_MODEL->getUIType() eq '19' or $FIELD_MODEL->getUIType() eq '20' or $FIELD_MODEL->getUIType() eq '300'} col-lg-9 {else}  col-lg-6 {/if}" id="{$MODULE_NAME}_detailView_fieldValue_{$FIELD_MODEL->getName()}" {if $FIELD_MODEL->getUIType() eq '19' or $FIELD_MODEL->getUIType() eq '20' or $FIELD_MODEL->getUIType() eq '300'} {assign var=COUNTER value=$COUNTER+1} {/if}>
											<span class="value" data-field-type="{$FIELD_MODEL->getFieldDataType()}" {if $FIELD_MODEL->getUIType() eq '19' or $FIELD_MODEL->getUIType() eq '20' or $FIELD_MODEL->getUIType() eq '21' or $FIELD_MODEL->getUIType() eq '300'} style="white-space:normal;" {/if}>
												{include file=\App\Layout::getTemplatePath($FIELD_MODEL->getUITypeModel()->getDetailViewTemplateName(), $MODULE_NAME) FIELD_MODEL=$FIELD_MODEL USER_MODEL=$USER_MODEL MODULE=$MODULE_NAME RECORD=$RECORD}
											</span>
											{assign var=EDIT value=false}
											{if in_array($FIELD_MODEL->getName(),['date_start','due_date']) && $MODULE eq 'Calendar'}
												{assign var=EDIT value=true}
											{/if}
											{if $IS_AJAX_ENABLED && $FIELD_MODEL->isEditable() eq 'true' && $FIELD_MODEL->isAjaxEditable() eq 'true' && !$EDIT}
												<span class="js-detail-quick-edit cursorPointer float-right ">
													&nbsp;<i class="fas fa-edit" title="{\App\Language::translate('LBL_EDIT',$MODULE_NAME)}"></i>
												</span>
												<span class="d-none edit">
													{include file=\App\Layout::getTemplatePath($FIELD_MODEL->getUITypeModel()->getTemplateName(), $MODULE_NAME) FIELD_MODEL=$FIELD_MODEL USER_MODEL=$USER_MODEL MODULE=$MODULE_NAME}
													{if $FIELD_MODEL->getFieldDataType() eq 'boolean' || $FIELD_MODEL->getFieldDataType() eq 'picklist'}
														<input type="hidden" class="fieldname" data-type="{$FIELD_MODEL->getFieldDataType()}" value='{$FIELD_MODEL->getName()}' data-prev-value='{$FIELD_MODEL->get('fieldvalue')}' />		
													{else}
														{assign var=FIELD_VALUE value=$FIELD_MODEL->getEditViewDisplayValue($FIELD_MODEL->get('fieldvalue'), $RECORD)}
														{if $FIELD_VALUE|is_array}
															{assign var=FIELD_VALUE value=\App\Json::encode($FIELD_VALUE)}
														{/if}
														<input type="hidden" class="fieldname" value='{$FIELD_MODEL->getName()}' data-type="{$FIELD_MODEL->getFieldDataType()}" data-prev-value='{\App\Purifier::encodeHtml($FIELD_VALUE)}' />
													{/if}
												</span>
											{/if}
										</div>
									</div>
								</div>
							{/if}
						{/foreach}
						{if $COUNTER eq 1}
							<div class="col-md-6 col-12 fieldsLabelValue"></div>
						{/if}
					</div>
				</div>
			</div>
		</div>
	{/if}
{/foreach}
{/strip}
