function [ecog_vals,ecog_err,ecog_names,ecog_erptime,ecog_erptime_err,ecog_bb_err68]=get_ecog_vals(electr,ecog_use,erp_parms,resamp_parms,chan_lbls,varargin)

if ~isempty(varargin)
    make_figure=varargin{1};
else
    make_figure=0;
end

clear ecog_vals ecog_bb ecog_bb_err ecog_g ecog_g_err ecog_erp ecog_erp_err ...
    ecog_bbplusg ecog_bbplusg_err ecog_bbpow ecog_bbpow_err

% ERP estimate:
ecog_erp=squeeze(mean(erp_parms(chan_lbls==electr,1:86,:,1),3));
ecog_erp_err(:,1)=squeeze(quantile(erp_parms(chan_lbls==electr,1:86,:,1),.025,3));
ecog_erp_err(:,2)=squeeze(quantile(erp_parms(chan_lbls==electr,1:86,:,1),.975,3));
ecog_erptime=squeeze(mean(erp_parms(chan_lbls==electr,1:86,:,2),3));
ecog_erptime_err(:,1)=squeeze(quantile(erp_parms(chan_lbls==electr,1:86,:,2),.025,3));
ecog_erptime_err(:,2)=squeeze(quantile(erp_parms(chan_lbls==electr,1:86,:,2),.975,3));
ecog_erp_base=erp_parms(chan_lbls==electr,1:86,:,3);
ecog_erp_base=ecog_erp_base(:);
ecog_erp_base_up=quantile(ecog_erp_base,.95);

% remove non-significant ERPs from the timing:
ecog_erptime(ecog_erp<ecog_erp_base_up)=NaN;
ecog_erptime_err(ecog_erp<ecog_erp_base_up,:)=NaN;
% remove unreliable ERPs from the timing:
% confidence interval larger than 80 ms
ecog_erptime((ecog_erptime_err(:,2)-ecog_erptime_err(:,1))>.08)=NaN;
ecog_erptime_err((ecog_erptime_err(:,2)-ecog_erptime_err(:,1))>.08,:)=NaN;

% subtract the baseline mean to get better 0-mean 
ecog_erp=ecog_erp-mean(ecog_erp_base);
ecog_erp_err=ecog_erp_err-mean(ecog_erp_base);

% Broadband estimate, one value per image:
ecog_bb=squeeze(mean(resamp_parms(chan_lbls==electr,1:86,:,2),3));
ecog_bb_err(:,1)=squeeze(quantile(resamp_parms(chan_lbls==electr,1:86,:,2),.025,3));
ecog_bb_err(:,2)=squeeze(quantile(resamp_parms(chan_lbls==electr,1:86,:,2),.975,3));
ecog_bb_err68(:,1)=squeeze(quantile(resamp_parms(chan_lbls==electr,1:86,:,2),.16,3));
ecog_bb_err68(:,2)=squeeze(quantile(resamp_parms(chan_lbls==electr,1:86,:,2),.84,3));

% make sure the ecog_bb has an interpretable zero value, subtract the
% average from the baseline period:
bb_base=squeeze(mean(resamp_parms(chan_lbls==electr,87,:,2),3));
%%%% power
ecog_bbpow=10.^ecog_bb-10.^bb_base;
ecog_bbpow_err(:,1)=10.^ecog_bb_err(:,1)-10.^bb_base;
ecog_bbpow_err(:,2)=10.^ecog_bb_err(:,2)-10.^bb_base;
%%%% just log-power
ecog_bb=ecog_bb-bb_base;
ecog_bb_err(:,1)=ecog_bb_err(:,1)-bb_base;
ecog_bb_err(:,2)=ecog_bb_err(:,2)-bb_base;


% Gamma estimate, one value per image:
ecog_g=squeeze(mean(resamp_parms(chan_lbls==electr,1:86,:,3),3));
ecog_g_err(:,1)=squeeze(quantile(resamp_parms(chan_lbls==electr,1:86,:,3),.025,3));
ecog_g_err(:,2)=squeeze(quantile(resamp_parms(chan_lbls==electr,1:86,:,3),.975,3));

% Broadband plus gamma estimate:
ecog_bb_t=squeeze(resamp_parms(chan_lbls==electr,1:86,:,2));
ecog_bb_t=ecog_bb_t-mean(squeeze(resamp_parms(chan_lbls==electr,87,:,2))); % Baseline correct
ecog_g_t=squeeze(resamp_parms(chan_lbls==electr,1:86,:,3));
ecog_bbplusg=ecog_bb_t+ecog_g_t;
ecog_bbplusg_err(:,1)=quantile(ecog_bbplusg,0.025,2);
ecog_bbplusg_err(:,2)=quantile(ecog_bbplusg,0.975,2);
ecog_bbplusg=mean(ecog_bbplusg,2);

% ecog_use=1; % 1 - bb, 2 - g, 3 - erp, 4 - bb+g
ecog_names={'broadband','gamma','erp','bbplusgamma','broadband_pow'};
if ecog_use==1
    ecog_vals=ecog_bb';
    ecog_err=ecog_bb_err;
elseif ecog_use==2
    ecog_vals=ecog_g';
    ecog_err=ecog_g_err;
elseif ecog_use==3
    ecog_vals=ecog_erp';
    ecog_err=ecog_erp_err;
elseif ecog_use==4
    ecog_vals=ecog_bbplusg;
    ecog_err=ecog_bbplusg_err;
elseif ecog_use==5
    ecog_vals=ecog_bbpow';
    ecog_err=ecog_bbpow_err;
end

% plot all ecog values
ecog_toplot={'ecog_bb','ecog_g','ecog_bbplusg','ecog_erp','ecog_erptime','ecog_bbpow'};
plot_pos=[1 3 5 2 4 6];

if make_figure==1
figure('Position',[0 0 1200 600])
for m=1:length(ecog_toplot)
    eval(['y_plot=' ecog_toplot{m} ';' 'y_err=' ecog_toplot{m} '_err;'])
    subplot(3,2,plot_pos(m)),hold on
    bar(y_plot,1,'b','EdgeColor',[1 1 1]);
    % plot error bars
    plot([1:86; 1:86],y_err','r','LineWidth',1);

    % plot stimulus cutoffs
    stim_change=[38.5 46.5 50.5 54.5 58.5 68.5 73.5 78.5 82.5];
    for k=1:length(stim_change)
        plot([stim_change(k) stim_change(k)],[0 max(y_plot)],'k','LineWidth',1)
    end
    text([19 40 46 52 55 61 70 74 79 84],min(y_plot)*ones(10,1)-quantile(y_plot,.50),{'space','orie','grat','pl','circ','zcon','sp','zsp','coh','nm'})

    ax = axis;
    axis([0 87 ax(3:4)]);
    ylabel([ecog_toplot{m} ' amplitude']);
    clear y_plot y_err
end
subplot(3,2,4)%erp timing plot:
plot([0 87],[.06 .06],'Color',[.5 .5 .5])
plot([0 87],[.08 .08],'Color',[.5 .5 .5])
plot([0 87],[.1 .1],'Color',[.5 .5 .5])
plot([0 87],[.12 .12],'Color',[.5 .5 .5])
ylim([0 .2])
set(gcf,'PaperPositionMode','auto')
end


% print('-dpng','-r300',['./figures/ecog_vals/' subj '_el'  int2str(electr) '_v1'])
% print('-depsc','-r300',['./figures/ecog_vals/' subj '_el'  int2str(electr) '_v1'])
