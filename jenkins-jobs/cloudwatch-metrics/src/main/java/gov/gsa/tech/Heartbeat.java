package gov.gsa.tech;

import com.amazonaws.services.cloudwatch.AmazonCloudWatch;
import com.amazonaws.services.cloudwatch.AmazonCloudWatchClientBuilder;
import com.amazonaws.services.cloudwatch.model.Dimension;
import com.amazonaws.services.cloudwatch.model.MetricDatum;
import com.amazonaws.services.cloudwatch.model.PutMetricDataRequest;
import com.amazonaws.services.cloudwatch.model.PutMetricDataResult;
import com.amazonaws.services.cloudwatch.model.StandardUnit;

public class Heartbeat {
  public static void main( String[] args ) {
    final AmazonCloudWatch cw =
      AmazonCloudWatchClientBuilder.defaultClient();

    MetricDatum datum = new MetricDatum()
      .withMetricName("heartbeat")
      .withUnit(StandardUnit.Count)
      .withValue(new Double(1));

    PutMetricDataRequest request = new PutMetricDataRequest()
      .withNamespace("Jenkins")
      .withMetricData(datum);

    PutMetricDataResult response = cw.putMetricData(request);
  }
}
