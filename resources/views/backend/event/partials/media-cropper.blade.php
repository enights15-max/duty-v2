<div
    class="modal fade event-image-cropper"
    id="eventImageCropModal"
    tabindex="-1"
    role="dialog"
    aria-labelledby="eventImageCropModalLabel"
    aria-hidden="true"
>
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title" id="eventImageCropModalLabel">{{ __('Adjust image') }}</h5>
                    <small class="text-muted text-light d-block" id="eventImageCropModalDescription">
                        {{ __('Drag to reframe and use zoom to fill the required ratio.') }}
                    </small>
                </div>
                <button type="button" class="close" data-dismiss="modal" aria-label="{{ __('Close') }}" id="eventImageCropCloseBtn">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="event-image-cropper__layout">
                    <div class="event-image-cropper__stage">
                        <div class="event-image-cropper__canvas-wrap">
                            <canvas id="eventImageCropCanvas" class="event-image-cropper__canvas"></canvas>
                        </div>
                    </div>

                    <div class="event-image-cropper__controls">
                        <div class="event-image-cropper__target">
                            <span class="event-image-cropper__target-label">{{ __('Output') }}</span>
                            <span class="event-image-cropper__target-value" id="eventImageCropTarget">1170 × 570</span>
                        </div>

                        <div class="event-image-cropper__range-wrap">
                            <label for="eventImageCropZoom">
                                <span>{{ __('Zoom') }}</span>
                                <strong id="eventImageCropZoomValue">100%</strong>
                            </label>
                            <input type="range" min="100" max="300" step="1" value="100" id="eventImageCropZoom" class="event-image-cropper__range">
                        </div>

                        <button type="button" class="btn btn-outline-light btn-sm" id="eventImageCropReset">
                            {{ __('Reset framing') }}
                        </button>

                        <div class="event-image-cropper__mini">
                            <img src="{{ asset('assets/admin/img/noimage.jpg') }}" alt="{{ __('Crop preview') }}" id="eventImageCropMiniPreview">
                        </div>

                        <ul class="event-image-cropper__tips">
                            <li>{{ __('You can upload any proportion. The system will export the exact required dimensions.') }}</li>
                            <li>{{ __('The main canvas already shows the final framing that will be saved.') }}</li>
                            <li>{{ __('If you simply close the modal, the automatic fit will be applied.') }}</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-light" data-dismiss="modal" id="eventImageCropAutoBtn">
                    {{ __('Use auto fit') }}
                </button>
                <button type="button" class="btn btn-primary" id="eventImageCropApplyBtn">
                    {{ __('Apply crop') }}
                </button>
            </div>
        </div>
    </div>
</div>
