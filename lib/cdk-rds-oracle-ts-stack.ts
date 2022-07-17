import { RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import {
  InstanceClass,
  InstanceSize,
  InstanceType,
  SecurityGroup,
  SubnetType,
  Vpc,
} from "aws-cdk-lib/aws-ec2";
import {
  Credentials,
  DatabaseInstance,
  DatabaseInstanceEngine,
  LicenseModel,
  OracleEngineVersion,
} from "aws-cdk-lib/aws-rds";
import { Bucket } from "aws-cdk-lib/aws-s3";
import { Construct } from "constructs";

export class CdkRdsOracleTsStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here

    //create s3 bucket
    const importBucket = new Bucket(this, "oracle-db-bucket", {
      removalPolicy: RemovalPolicy.DESTROY,
    });
    //create vpc:
    const dbVpc = new Vpc(this, "oracle-db-vpc", {
      maxAzs: 2,
      cidr: "10.0.0.0/16",
      subnetConfiguration: [
        {
          name: "oracle-db-public-sn",
          subnetType: SubnetType.PUBLIC,
          cidrMask: 24,
        },
      ],

      enableDnsHostnames: true,
      enableDnsSupport: true,
    });
    //create db instance:
    const db = new DatabaseInstance(this, "oracle-db-dev", {
      engine: DatabaseInstanceEngine.oracleSe2({
        version: OracleEngineVersion.VER_19_0_0_0_2021_04_R1,
      }),
      licenseModel: LicenseModel.LICENSE_INCLUDED,
      vpc: dbVpc,
      vpcSubnets: dbVpc.selectSubnets({
        subnetGroupName: "oracle-db-public-sn",
      }),
      publiclyAccessible: true,
      databaseName: "akvdev",
      credentials: Credentials.fromGeneratedSecret("syscdk"),
      instanceType: InstanceType.of(
        InstanceClass.BURSTABLE3,
        InstanceSize.SMALL
      ),
      s3ImportBuckets: [importBucket],
      removalPolicy: RemovalPolicy.DESTROY,
    });
    db.connections.allowDefaultPortFromAnyIpv4("allow connections to DB");
  }
}
