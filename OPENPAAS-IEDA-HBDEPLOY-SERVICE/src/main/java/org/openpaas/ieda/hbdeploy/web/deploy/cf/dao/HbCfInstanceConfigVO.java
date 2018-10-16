package org.openpaas.ieda.hbdeploy.web.deploy.cf.dao;

import java.sql.Date;

public class HbCfInstanceConfigVO {
    
    private int id;
    private int recid;
    private String iaasType;
    private String instanceConfigName;
    private String defaultConfigInfo;
    private String networkConfigInfo;
    
    private String nats_z1;
    private String blobstore_z1;
    private String router_z1;
    private String loggregator_z1;
    private String doppler_z1;
    private String etcd_z1;
    private String consul_z1;
    private String clock_z1;
    private String uaa_z1;
    private String api_z1;
    private String api_worker_z1;
    private String postgres_z1;
    
    private String nats_z2;
    private String blobstore_z2;
    private String router_z2;
    private String loggregator_z2;
    private String doppler_z2;
    private String etcd_z2;
    private String consul_z2;
    private String clock_z2;
    private String uaa_z2;
    private String api_z2;
    private String api_worker_z2;
    private String postgres_z2;
    
    private String createUserId;
    private Date createDate;
    private String updateUserId;
    private Date updateDate;
    
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public int getRecid() {
        return recid;
    }
    public void setRecid(int recid) {
        this.recid = recid;
    }
    public String getIaasType() {
        return iaasType;
    }
    public void setIaasType(String iaasType) {
        this.iaasType = iaasType;
    }
    public String getInstanceConfigName() {
        return instanceConfigName;
    }
    public void setInstanceConfigName(String instanceConfigName) {
        this.instanceConfigName = instanceConfigName;
    }
    public String getDefaultConfigInfo() {
        return defaultConfigInfo;
    }
    public void setDefaultConfigInfo(String defaultConfigInfo) {
        this.defaultConfigInfo = defaultConfigInfo;
    }
    public String getNetworkConfigInfo() {
        return networkConfigInfo;
    }
    public void setNetworkConfigInfo(String networkConfigInfo) {
        this.networkConfigInfo = networkConfigInfo;
    }
    public String getNats_z1() {
        return nats_z1;
    }
    public void setNats_z1(String nats_z1) {
        this.nats_z1 = nats_z1;
    }
    public String getBlobstore_z1() {
        return blobstore_z1;
    }
    public void setBlobstore_z1(String blobstore_z1) {
        this.blobstore_z1 = blobstore_z1;
    }
    public String getRouter_z1() {
        return router_z1;
    }
    public void setRouter_z1(String router_z1) {
        this.router_z1 = router_z1;
    }
    public String getLoggregator_z1() {
        return loggregator_z1;
    }
    public void setLoggregator_z1(String loggregator_z1) {
        this.loggregator_z1 = loggregator_z1;
    }
    public String getDoppler_z1() {
        return doppler_z1;
    }
    public void setDoppler_z1(String doppler_z1) {
        this.doppler_z1 = doppler_z1;
    }
    public String getEtcd_z1() {
        return etcd_z1;
    }
    public void setEtcd_z1(String etcd_z1) {
        this.etcd_z1 = etcd_z1;
    }
    public String getConsul_z1() {
        return consul_z1;
    }
    public void setConsul_z1(String consu_z1) {
        this.consul_z1 = consu_z1;
    }
    public String getClock_z1() {
        return clock_z1;
    }
    public void setClock_z1(String clock_z1) {
        this.clock_z1 = clock_z1;
    }
    public String getUaa_z1() {
        return uaa_z1;
    }
    public void setUaa_z1(String uaa_z1) {
        this.uaa_z1 = uaa_z1;
    }
    public String getApi_z1() {
        return api_z1;
    }
    public void setApi_z1(String api_z1) {
        this.api_z1 = api_z1;
    }
    public String getApi_worker_z1() {
        return api_worker_z1;
    }
    public void setApi_worker_z1(String api_worker_z1) {
        this.api_worker_z1 = api_worker_z1;
    }
    public String getPostgres_z1() {
        return postgres_z1;
    }
    public void setPostgres_z1(String postgres_z1) {
        this.postgres_z1 = postgres_z1;
    }
    public String getNats_z2() {
        return nats_z2;
    }
    public void setNats_z2(String nats_z2) {
        this.nats_z2 = nats_z2;
    }
    public String getBlobstore_z2() {
        return blobstore_z2;
    }
    public void setBlobstore_z2(String blobstore_z2) {
        this.blobstore_z2 = blobstore_z2;
    }
    public String getRouter_z2() {
        return router_z2;
    }
    public void setRouter_z2(String router_z2) {
        this.router_z2 = router_z2;
    }
    public String getLoggregator_z2() {
        return loggregator_z2;
    }
    public void setLoggregator_z2(String loggregator_z2) {
        this.loggregator_z2 = loggregator_z2;
    }
    public String getDoppler_z2() {
        return doppler_z2;
    }
    public void setDoppler_z2(String doppler_z2) {
        this.doppler_z2 = doppler_z2;
    }
    public String getEtcd_z2() {
        return etcd_z2;
    }
    public void setEtcd_z2(String etcd_z2) {
        this.etcd_z2 = etcd_z2;
    }
    public String getConsul_z2() {
        return consul_z2;
    }
    public void setConsul_z2(String consul_z2) {
        this.consul_z2 = consul_z2;
    }
    public String getClock_z2() {
        return clock_z2;
    }
    public void setClock_z2(String clock_z2) {
        this.clock_z2 = clock_z2;
    }
    public String getUaa_z2() {
        return uaa_z2;
    }
    public void setUaa_z2(String uaa_z2) {
        this.uaa_z2 = uaa_z2;
    }
    public String getApi_z2() {
        return api_z2;
    }
    public void setApi_z2(String api_z2) {
        this.api_z2 = api_z2;
    }
    public String getApi_worker_z2() {
        return api_worker_z2;
    }
    public void setApi_worker_z2(String api_worker_z2) {
        this.api_worker_z2 = api_worker_z2;
    }
    public String getPostgres_z2() {
        return postgres_z2;
    }
    public void setPostgres_z2(String postgres_z2) {
        this.postgres_z2 = postgres_z2;
    }
    public String getCreateUserId() {
        return createUserId;
    }
    public void setCreateUserId(String createUserId) {
        this.createUserId = createUserId;
    }
    public Date getCreateDate() {
        return createDate;
    }
    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }
    public String getUpdateUserId() {
        return updateUserId;
    }
    public void setUpdateUserId(String updateUserId) {
        this.updateUserId = updateUserId;
    }
    public Date getUpdateDate() {
        return updateDate;
    }
    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }
}
