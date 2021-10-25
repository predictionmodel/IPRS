
library(dplyr)
library(ggthemes)
IPRS_stratification_population<-function(Outcome,Environment,IPRS_Analysis_Data){
  Outcome<-deparse(substitute(Outcome))
  Environment<-deparse(substitute(Environment))
  IPRS_Analysis_Data<-as.data.frame(IPRS_Analysis_Data)
  theme_bar <- function(..., bg='white'){
    require(grid)
    theme_classic(...) +
      theme(rect=element_rect(fill=bg),
            plot.margin=unit(rep(0.5,4), 'lines'),
            panel.background=element_rect(fill='transparent', color='black'),
            panel.border=element_rect(fill='transparent', color='transparent'),
            panel.grid=element_blank(),#ȥ������
            axis.title.x = element_blank(),#ȥx���ǩ
            axis.title.y=element_text(face = "bold",size = 14),#y���ǩ�Ӵּ������С
            axis.text = element_text(face = "bold",size = 12),#������̶ȱ�ǩ�Ӵ�
            # axis.ticks = element_line(color='black'),#������̶���
            # axis.ticks.margin = unit(0.8,"lines"),
            legend.title=element_blank(),#ȥ��ͼ������
            # legend.justification=c(1,0),#ͼ���ڻ�����λ��(��ͼ������)
            legend.position=c(0.28, 0.9),#ͼ���ڻ�ͼ�����λ��
            # legend.position='top',#ͼ�����ڶ���
            legend.direction = "horizontal",#����ͼ��ˮƽ����
            # legend.spacing.x = unit(2, 'cm'),
            legend.text = element_text(face = "bold",size = 12,margin = margin(r=20)),
            legend.background = element_rect( linetype="solid",colour ="black")
            # legend.margin=margin(0,0,-7,0)#ͼ�����ͼ�����Ե�ľ���
            # legend.box.margin =margin(-10,0,0,0)
      )
  }
  
  IPRS_prediction_model<-glm(IPRS_Analysis_Data[,Outcome]~IPRS_Analysis_Data[,"iPRS"]+IPRS_Analysis_Data[,Environment],family="binomial")
  predictive_value <- predict(IPRS_prediction_model,IPRS_Analysis_Data)
  IPRS_Analysis_Data$predictive_value<-predictive_value
  Preva_IPRS<-data.frame(number=c(1:3),PRS_type=c("IPRS","IPRS","IPRS"),
                         PRS_level=c("Low","Medium","High"),preva=c(NA))
  
  IPRS_low5<-IPRS_Analysis_Data[IPRS_Analysis_Data$predictive_value<=quantile(IPRS_Analysis_Data$predictive_value,0.05),]
  IPRS_low5$PRS_level<-"Low"
  Preva_IPRS$preva[1]<-sum(IPRS_low5[,Outcome]==1)/length(IPRS_low5[,Outcome])
  IPRS_mediate<-IPRS_Analysis_Data[IPRS_Analysis_Data$predictive_value>quantile(IPRS_Analysis_Data$predictive_value,0.05)&
                                     IPRS_Analysis_Data$predictive_value<quantile(IPRS_Analysis_Data$predictive_value,0.95),]
  IPRS_mediate$PRS_level<-"Medium"
  Preva_IPRS$preva[2]<-sum(IPRS_mediate[,Outcome]==1)/length(IPRS_mediate[,Outcome])
  IPRS_top5<-IPRS_Analysis_Data[IPRS_Analysis_Data$predictive_value>=quantile(IPRS_Analysis_Data$predictive_value,0.95),]
  IPRS_top5$PRS_level<-"High"
  Preva_IPRS$preva[3]<-sum(IPRS_top5[,Outcome]==1)/length(IPRS_top5[,Outcome])
  
  table_prevalence1<-matrix(c(nrow(IPRS_Analysis_Data)*Preva_IPRS$preva[1],nrow(IPRS_Analysis_Data)*Preva_IPRS$preva[2],nrow(IPRS_Analysis_Data)*Preva_IPRS$preva[3]),nrow=2,ncol=3)
  if(chisq.test(table_prevalence1)$p.value==0){
    p_label<-paste0("P < 2.2e-16")
  }else{
    p_label<-paste0("P=",signif(chisq.test(table_prevalence1)$p.value,4))
  }
  
  Preva_IPRS %>%
    select(PRS_type,PRS_level,preva) %>%
    group_by(PRS_type,PRS_level) %>%
    ggplot(aes(x=PRS_level,y=preva,fill=PRS_type))+
    geom_bar(position=position_dodge(0.6),width=0.5,stat='identity')+
    scale_y_continuous(limits=c(0,1.25),expand = c(0, 0))+#����x�����ͼ���ļ�϶
    scale_x_discrete(limits=c("Low","Medium","High"))+
    scale_fill_manual(values="#0073c2")+
    theme_few()+
    theme(legend.position = c(.2,.85)) + ##�趨legendλ��
    labs(fill = "PRS type", x = "PRS level",y = "Prevalence")+
    geom_text(aes(y=0.9,x=2,label=p_label),size=6)-> p2
  return(print(p2))
}


