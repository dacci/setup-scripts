# Usage example with CloudFormation

```yaml
Parameters:
  ImageId:
    Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
    Default: /aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
  SubnetId:
    Type: AWS::EC2::Subnet::Id
  SecurityGroupIds:
    Type: List<AWS::EC2::SecurityGroup::Id>
Resources:
  Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Ref ImageId
      InstanceType: t2.micro
      KeyName: !Ref KeyName
      SecurityGroupIds: !Ref SecurityGroupIds
      SubnetId: !Ref SubnetId
      UserData:
        Fn::Base64:
          Fn::Sub: |
            <powershell>
            cfn-init -v --region ${AWS::Region} --stack ${AWS::StackName} --resource Instance -c default
            cfn-signal -e $LASTEXITCODE --region ${AWS::Region} --stack ${AWS::StackName} --resource Instance
            </powershell>
    CreationPolicy:
      ResourceSignal:
        Count: 1
        Timeout: PT10M
    Metadata:
      AWS::CloudFormation::Init:
        configSets:
          default:
            - config
        config:
          commands:
            Install-WindowsTerminal:
              command:
                - powershell
                - -Command
                - Invoke-RestMethod https://github.com/dacci/setup-scripts/raw/main/windows/Install-WindowsTerminal.ps1 | Invoke-Expression
              waitAfterCompletion: 0
            Install-WinGet:
              command:
                - powershell
                - -Command
                - Invoke-RestMethod https://github.com/dacci/setup-scripts/raw/main/windows/Install-WinGet.ps1 | Invoke-Expression; Restart-Computer -Force
              waitAfterCompletion: forever
```
